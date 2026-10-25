import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraRTCService {
  late RtcEngine _engine;
  bool _isInitialized = false;
  bool _isJoined = false;

  final StreamController<bool> _joinStateController =
      StreamController<bool>.broadcast();
  final StreamController<String> _userStateController =
      StreamController<String>.broadcast();

  Stream<bool> get joinState => _joinStateController.stream;
  Stream<String> get userState => _userStateController.stream;

  bool get isInitialized => _isInitialized;
  bool get isJoined => _isJoined;

  /// Initialize Agora RTC Engine
  Future<void> initialize(String appId) async {
    try {
      debugPrint('🎤 Initializing Agora RTC Engine...');

      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Create engine
      _engine = createAgoraRtcEngine();

      // Initialize
      await _engine.initialize(RtcEngineContext(appId: appId));

      // Enable audio
      await _engine.enableAudio();

      // Set audio profile
      await _engine.setAudioProfile(
        profile: AudioProfileType.speechStandard,
        scenario: AudioScenarioType.chatRoom,
      );

      // Set event handlers
      _setupEventHandlers();

      _isInitialized = true;
      debugPrint('✅ Agora RTC Engine initialized');
    } catch (e) {
      debugPrint('❌ Error initializing Agora RTC: $e');
      rethrow;
    }
  }

  /// Setup event handlers
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
            '✅ Joined channel: ${connection.channelId}, uid: ${connection.localUid}',
          );
          _isJoined = true;
          _joinStateController.add(true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('👤 Remote user joined: $remoteUid');
          _userStateController.add('user_joined_$remoteUid');
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('👤 Remote user offline: $remoteUid');
              _userStateController.add('user_offline_$remoteUid');
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint('❌ Left channel');
          _isJoined = false;
          _joinStateController.add(false);
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('❌ Agora error: $err - $msg');
        },
      ),
    );
  }

  /// Join a channel
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    try {
      if (!_isInitialized) {
        throw Exception('Agora RTC not initialized');
      }

      debugPrint('🎤 Joining channel: $channelName with uid: $uid');

      await _engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
          publishMicrophoneTrack: true,
          publishCameraTrack: false,
        ),
      );

      debugPrint('✅ Join channel request sent');
    } catch (e) {
      debugPrint('❌ Error joining channel: $e');
      rethrow;
    }
  }

  /// Leave channel
  Future<void> leaveChannel() async {
    try {
      if (!_isInitialized) return;

      debugPrint('🚪 Leaving channel...');
      await _engine.leaveChannel();
      _isJoined = false;
      _joinStateController.add(false);
      debugPrint('✅ Left channel');
    } catch (e) {
      debugPrint('❌ Error leaving channel: $e');
      rethrow;
    }
  }

  /// Mute/unmute microphone
  Future<void> setMicrophoneMute(bool mute) async {
    try {
      await _engine.muteLocalAudioStream(mute);
      debugPrint(mute ? '🔇 Microphone muted' : '🔊 Microphone unmuted');
    } catch (e) {
      debugPrint('❌ Error setting microphone mute: $e');
      rethrow;
    }
  }

  /// Enable/disable audio
  Future<void> enableAudio(bool enable) async {
    try {
      if (enable) {
        await _engine.enableAudio();
        debugPrint('✅ Audio enabled');
      } else {
        await _engine.disableAudio();
        debugPrint('✅ Audio disabled');
      }
    } catch (e) {
      debugPrint('❌ Error enabling/disabling audio: $e');
      rethrow;
    }
  }

  /// Get connection state
  String getConnectionState() {
    return _isJoined ? 'connected' : 'disconnected';
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await leaveChannel();
      await _engine.release();
      await _joinStateController.close();
      await _userStateController.close();
      _isInitialized = false;
      debugPrint('✅ Agora RTC Service disposed');
    } catch (e) {
      debugPrint('❌ Error disposing Agora RTC: $e');
    }
  }
}
