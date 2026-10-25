import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class AgoraConversationalVoiceAgent extends StatefulWidget {
  final String userId;
  final String agoraAppId;
  final String mode;

  const AgoraConversationalVoiceAgent({
    super.key,
    required this.userId,
    required this.agoraAppId,
    this.mode = 'education',
  });

  @override
  State<AgoraConversationalVoiceAgent> createState() =>
      _AgoraConversationalVoiceAgentState();
}

class _AgoraConversationalVoiceAgentState
    extends State<AgoraConversationalVoiceAgent> {
  late RtcEngine _engine;
  final ApiService _apiService = ApiService();

  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isMicMuted = false;
  String? _agentId;
  String _connectionStatus = 'Initializing...';
  final List<int> _remoteUids = [];

  // Color palette
  static const Color _backgroundColor = Color(0xFFFAF5F5);
  static const Color _purpleAccent = Color(0xFFD4C4E8);
  static const Color _greenAccent = Color(0xFFB8D4C8);

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    try {
      debugPrint('🎤 Initializing Agora RTC Engine...');

      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Create engine
      _engine = createAgoraRtcEngine();

      // Initialize with communication profile
      await _engine.initialize(
        RtcEngineContext(
          appId: widget.agoraAppId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // Enable audio
      await _engine.enableAudio();

      // Force audio to speaker (not earpiece) for better hearing
      await _engine.setDefaultAudioRouteToSpeakerphone(true);

      // Setup event handlers
      _setupEventHandlers();

      setState(() {
        _isInitialized = true;
        _connectionStatus = 'Ready to connect';
      });

      debugPrint('✅ Agora RTC Engine initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Agora: $e');
      if (mounted) {
        setState(() {
          _connectionStatus = 'Initialization failed: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
            '✅ Joined channel: ${connection.channelId}, uid: ${connection.localUid}',
          );
          if (mounted) {
            setState(() {
              _isJoined = true;
              _connectionStatus = 'Connected - AI agent online';
            });
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('👤 Remote user joined: $remoteUid');
          if (remoteUid == 999) {
            debugPrint('🤖 AI Agent (UID 999) has joined the channel!');
          }
          if (mounted) {
            setState(() {
              _remoteUids.add(remoteUid);
              if (remoteUid == 999) {
                _connectionStatus = 'AI Agent connected - listening...';
              }
            });
          }
        },
        onAudioVolumeIndication:
            (
              RtcConnection connection,
              List<AudioVolumeInfo> speakers,
              int speakerNumber,
              int totalVolume,
            ) {
              for (var speaker in speakers) {
                if (speaker.uid == 999 && speaker.volume! > 0) {
                  debugPrint('🔊 AI Agent speaking: volume ${speaker.volume}');
                }
              }
            },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('👤 Remote user offline: $remoteUid');
              if (mounted) {
                setState(() {
                  _remoteUids.remove(remoteUid);
                });
              }
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('❌ Left channel');
          if (mounted) {
            setState(() {
              _isJoined = false;
              _remoteUids.clear();
              _connectionStatus = 'Disconnected';
            });
          }
        },
        onError: (ErrorCodeType err, String msg) {
          // Token expired is a non-fatal error that can occur after connection
          // The connection remains stable, so we just log it
          if (err == ErrorCodeType.errTokenExpired) {
            debugPrint('⚠️ Token expired (non-fatal): $msg');
            return;
          }

          // Log other errors
          debugPrint('❌ Agora error: $err - $msg');

          // Handle critical errors
          if (err == ErrorCodeType.errJoinChannelRejected ||
              err == ErrorCodeType.errInvalidToken) {
            if (mounted) {
              setState(() {
                _connectionStatus = 'Connection error: ${err.toString()}';
              });
            }
          }
        },
      ),
    );
  }

  Future<void> _startVoiceConversation() async {
    try {
      if (!_isInitialized) {
        throw Exception('Agora not initialized');
      }

      // Leave any existing channel first
      if (_isJoined) {
        await _engine.leaveChannel();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() {
        _connectionStatus = 'Connecting...';
      });

      // Generate channel name
      final channelName =
          'mensa_voice_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}';

      // Generate UID from user ID hash (Agora requires numeric UID)
      final userUid = widget.userId.hashCode.abs() % 1000000;

      debugPrint('🎤 Starting voice conversation on channel: $channelName');
      debugPrint('👤 User UID: $userUid');

      // Start AI agent on backend FIRST (server generates agent token internally)
      debugPrint('🤖 Starting AI agent...');
      final agentResponse = await _apiService.startAgoraAgent(
        channelName: channelName,
        agentName: 'mensa_agent_${DateTime.now().millisecondsSinceEpoch}',
        mode: widget.mode,
      );

      if (agentResponse == null || !agentResponse['success']) {
        throw Exception(
          'Failed to start AI agent: ${agentResponse?['error'] ?? 'Unknown error'}',
        );
      }

      setState(() {
        _agentId = agentResponse['agentId'];
      });

      debugPrint('✅ AI agent started: $_agentId');

      // Now get a fresh token for the user to join the channel
      final userTokenResponse = await _apiService.generateRTCToken(
        channelName: channelName,
        uid: userUid,
      );

      if (userTokenResponse == null) {
        throw Exception('Failed to generate user RTC token');
      }

      final userToken = userTokenResponse['token'];
      debugPrint(
        '🔑 User RTC Token generated: ${userToken.substring(0, 20)}... (expires in ${userTokenResponse['expiresIn']} seconds)',
      );

      // Join Agora channel with retry logic
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          debugPrint(
            '📞 Joining channel (attempt ${retryCount + 1}/$maxRetries)...',
          );

          await _engine.joinChannel(
            token: userToken,
            channelId: channelName,
            uid: userUid,
            options: const ChannelMediaOptions(
              autoSubscribeAudio: true,
              autoSubscribeVideo: false,
              publishMicrophoneTrack: true,
              publishCameraTrack: false,
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
            ),
          );

          debugPrint('✅ Successfully joined channel');

          // Ensure audio is routed to speaker
          await _engine.setDefaultAudioRouteToSpeakerphone(true);

          // Enable audio volume indication to monitor agent speaking
          await _engine.enableAudioVolumeIndication(
            interval: 200,
            smooth: 3,
            reportVad: true,
          );

          setState(() {
            _isJoined = true;
            _connectionStatus = 'Connected - waiting for AI agent...';
          });

          // Fetch and display greeting from AI
          _fetchAndDisplayGreeting();
          break;
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception(
              'Failed to join channel after $maxRetries attempts: $e',
            );
          }
          debugPrint(
            '⚠️ Join attempt failed, retrying... ($retryCount/$maxRetries)',
          );
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      debugPrint('✅ Voice conversation started with agent: $_agentId');
    } catch (e) {
      debugPrint('❌ Error starting voice conversation: $e');
      if (mounted) {
        setState(() {
          _connectionStatus = 'Connection failed: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _endVoiceConversation() async {
    try {
      setState(() {
        _connectionStatus = 'Disconnecting...';
      });

      // Stop AI agent
      if (_agentId != null) {
        final stopResult = await _apiService.stopAgoraAgent(agentId: _agentId!);
        if (stopResult != null && stopResult['success']) {
          debugPrint('✅ AI agent stopped');
        } else {
          debugPrint('⚠️ Agent stop returned: $stopResult');
        }
      }

      // Leave channel
      await _engine.leaveChannel();

      setState(() {
        _isJoined = false;
        _agentId = null;
        _connectionStatus = 'Disconnected';
      });

      debugPrint('✅ Voice conversation ended');
    } catch (e) {
      debugPrint('❌ Error ending voice conversation: $e');
      if (mounted) {
        setState(() {
          _isJoined = false;
          _agentId = null;
          _connectionStatus = 'Disconnected';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversation ended'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _fetchAndDisplayGreeting() async {
    try {
      debugPrint('🎤 Fetching greeting from AI...');
      final greeting = await _apiService.getAgoraGreeting(mode: widget.mode);

      if (greeting != null && mounted) {
        debugPrint('✅ Greeting received: $greeting');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(greeting),
            duration: const Duration(seconds: 4),
            backgroundColor: _greenAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching greeting: $e');
    }
  }

  Future<void> _toggleMicrophone() async {
    try {
      setState(() {
        _isMicMuted = !_isMicMuted;
      });

      await _engine.muteLocalAudioStream(_isMicMuted);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isMicMuted ? '🔇 Microphone muted' : '🔊 Microphone unmuted',
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      debugPrint(_isMicMuted ? '🔇 Microphone muted' : '🔊 Microphone unmuted');
    } catch (e) {
      debugPrint('❌ Error toggling microphone: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.mode == 'ranting'
                  ? 'Chat with Mena - Your Emotional Support'
                  : 'Chat with Mena - Your Health Educator',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _connectionStatus,
              style: TextStyle(
                color: _isJoined ? _greenAccent : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.mode == 'ranting'
                        ? 'Mena is here to listen and provide emotional support. Share your feelings, concerns, and experiences. For medical advice, always consult a healthcare provider.'
                        : 'Chat with Mena for educational information about girls\' health including periods, PCOS, PCOD, endometriosis, and menopause. For medical advice, always consult a healthcare provider.',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Connection info
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isJoined ? Icons.check_circle : Icons.phone,
                          size: 64,
                          color: _isJoined ? _greenAccent : _purpleAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isJoined
                              ? widget.mode == 'ranting'
                                    ? 'Connected to Mena'
                                    : 'Connected to Mena'
                              : widget.mode == 'ranting'
                              ? 'Ready to Share Your Feelings'
                              : 'Ready to Chat with Mena',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _connectionStatus,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        if (_isJoined) ...[
                          const SizedBox(height: 16),
                          // Listening indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _greenAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _greenAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mena is listening...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.mode == 'ranting'
                                ? 'Share your feelings and concerns - Mena is here to listen'
                                : 'Ask Mena about your health questions',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (!_isJoined)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isInitialized
                            ? _startVoiceConversation
                            : null,
                        icon: const Icon(Icons.phone),
                        label: Text(
                          widget.mode == 'ranting'
                              ? 'Start Talking to Mena'
                              : 'Chat with Mena',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _greenAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleMicrophone,
                            icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic),
                            label: Text(_isMicMuted ? 'Unmute' : 'Mute'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isMicMuted
                                  ? Colors.red
                                  : _purpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _endVoiceConversation,
                            icon: const Icon(Icons.call_end),
                            label: const Text('End Call'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
