import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';

class AgoraVoiceService {
  late FlutterSoundRecorder _recorder;
  late AudioPlayer _audioPlayer;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;

  final StreamController<bool> _recordingStateController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingStateController =
      StreamController<bool>.broadcast();
  final StreamController<double> _recordingProgressController =
      StreamController<double>.broadcast();

  Stream<bool> get recordingState => _recordingStateController.stream;
  Stream<bool> get playingState => _playingStateController.stream;
  Stream<double> get recordingProgress => _recordingProgressController.stream;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  AgoraVoiceService() {
    _recorder = FlutterSoundRecorder();
    _audioPlayer = AudioPlayer();
  }

  /// Initialize voice service
  Future<void> initialize() async {
    try {
      debugPrint('🎤 Initializing Agora Voice Service...');

      // Request permissions
      await [Permission.microphone, Permission.camera].request();

      // Initialize recorder
      await _recorder.openRecorder();
      debugPrint('✅ Voice recorder initialized');
    } catch (e) {
      debugPrint('❌ Error initializing voice service: $e');
      rethrow;
    }
  }

  /// Start recording voice
  Future<void> startRecording() async {
    try {
      if (_isRecording) {
        debugPrint('⚠️ Already recording');
        return;
      }

      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordedFilePath = '${tempDir.path}/agora_voice_$timestamp.wav';

      debugPrint('🎤 Starting voice recording to: $_recordedFilePath');

      await _recorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.pcm16WAV,
      );

      _isRecording = true;
      _recordingStateController.add(true);
      debugPrint('✅ Recording started');
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      _isRecording = false;
      _recordingStateController.add(false);
      rethrow;
    }
  }

  /// Stop recording and return file path
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        debugPrint('⚠️ Not recording');
        return null;
      }

      debugPrint('🛑 Stopping recording...');

      // Stop the recorder
      final path = await _recorder.stopRecorder();

      // Update state immediately
      _isRecording = false;
      _recordingStateController.add(false);

      debugPrint('✅ Recording stopped: $path');

      // Verify file exists
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (file.existsSync()) {
          final size = await file.length();
          debugPrint('📁 Recording file size: $size bytes');
        }
      }

      return path;
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      _isRecording = false;
      _recordingStateController.add(false);
      rethrow;
    }
  }

  /// Play audio response
  Future<void> playAudio(String filePath) async {
    try {
      if (_isPlaying) {
        debugPrint('⚠️ Already playing');
        return;
      }

      debugPrint('🔊 Playing audio: $filePath');

      _isPlaying = true;
      _playingStateController.add(true);

      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();

      // Wait for playback to complete
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      _isPlaying = false;
      _playingStateController.add(false);
      debugPrint('✅ Audio playback completed');
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      _isPlaying = false;
      _playingStateController.add(false);
      rethrow;
    }
  }

  /// Play TTS audio from bytes
  Future<void> playTTSAudio(List<int> audioBytes) async {
    try {
      if (_isPlaying) {
        debugPrint('⚠️ Already playing');
        return;
      }

      debugPrint('🔊 Playing TTS audio (${audioBytes.length} bytes)');

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/tts_response.wav');
      await tempFile.writeAsBytes(audioBytes);

      await playAudio(tempFile.path);
    } catch (e) {
      debugPrint('❌ Error playing TTS audio: $e');
      rethrow;
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _playingStateController.add(false);
      debugPrint('✅ Playback stopped');
    } catch (e) {
      debugPrint('❌ Error stopping playback: $e');
      rethrow;
    }
  }

  /// Get recording duration
  Future<Duration?> getRecordingDuration() async {
    try {
      if (_recordedFilePath == null) return null;

      final file = File(_recordedFilePath!);
      if (!file.existsSync()) return null;

      // For now, return file size as proxy
      final size = await file.length();
      // Rough estimate: 16kHz, 16-bit = 32KB per second
      return Duration(milliseconds: (size ~/ 32).toInt());
    } catch (e) {
      debugPrint('❌ Error getting recording duration: $e');
      return null;
    }
  }

  /// Get recorded file path
  String? getRecordedFilePath() => _recordedFilePath;

  /// Clear recorded file
  Future<void> clearRecording() async {
    try {
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (file.existsSync()) {
          await file.delete();
          debugPrint('✅ Recording cleared');
        }
      }
      _recordedFilePath = null;
    } catch (e) {
      debugPrint('❌ Error clearing recording: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _recorder.closeRecorder();
      await _audioPlayer.dispose();
      await _recordingStateController.close();
      await _playingStateController.close();
      await _recordingProgressController.close();
      debugPrint('✅ Voice service disposed');
    } catch (e) {
      debugPrint('❌ Error disposing voice service: $e');
    }
  }
}
