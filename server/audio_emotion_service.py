#!/usr/bin/env python3
"""
Audio Emotion Detection Service using Hugging Face Model
Uses: Hatman/audio-emotion-detection
"""

import os
import sys
import json
import base64
from io import BytesIO
from transformers import pipeline
import librosa
import numpy as np

class AudioEmotionDetector:
    def __init__(self):
        """Initialize the audio emotion detection pipeline"""
        self.api_key = os.getenv('HUGGING_FACE_API_KEY')
        
        if not self.api_key:
            print("⚠️ HUGGING_FACE_API_KEY not set")
            sys.exit(1)
        
        print("🎤 Loading Hugging Face audio emotion detection model...")
        try:
            # Load the audio classification pipeline
            self.pipe = pipeline(
                "audio-classification",
                model="Hatman/audio-emotion-detection",
                device=0 if self._has_gpu() else -1
            )
            print("✅ Model loaded successfully")
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            sys.exit(1)
    
    def _has_gpu(self):
        """Check if GPU is available"""
        try:
            import torch
            return torch.cuda.is_available()
        except:
            return False
    
    def detect_emotion(self, audio_data, sample_rate=16000):
        """
        Detect emotion from audio data
        
        Args:
            audio_data: Audio samples as numpy array or bytes
            sample_rate: Sample rate of audio (default 16000 Hz)
        
        Returns:
            dict: Emotion detection results
        """
        try:
            print(f"🎤 Processing audio ({len(audio_data)} bytes)...")
            
            # Convert bytes to numpy array if needed
            if isinstance(audio_data, bytes):
                audio_array = np.frombuffer(audio_data, dtype=np.int16).astype(np.float32) / 32768.0
            else:
                audio_array = audio_data
            
            # Resample if needed
            if sample_rate != 16000:
                audio_array = librosa.resample(audio_array, orig_sr=sample_rate, target_sr=16000)
            
            # Run emotion detection
            print("🔍 Running emotion detection...")
            results = self.pipe(audio_array, sampling_rate=16000)
            
            print(f"✅ Detection complete: {results}")
            
            # Parse results
            emotions = []
            for result in results:
                emotions.append({
                    'emotion': result['label'],
                    'confidence': float(result['score'])
                })
            
            # Sort by confidence
            emotions.sort(key=lambda x: x['confidence'], reverse=True)
            
            # Get top emotion
            top_emotion = emotions[0] if emotions else {'emotion': 'neutral', 'confidence': 0}
            
            # Map to mood
            mood_mapping = {
                'happy': 'Happy',
                'sad': 'Sad',
                'angry': 'Stressed',
                'fear': 'Anxious',
                'surprise': 'Energetic',
                'neutral': 'Calm',
                'disgust': 'Stressed',
                'calm': 'Calm',
                'joy': 'Happy',
                'sorrow': 'Sad',
                'anger': 'Stressed',
            }
            
            emotion_key = top_emotion['emotion'].lower()
            mood = mood_mapping.get(emotion_key, 'Calm')
            
            return {
                'success': True,
                'emotion': top_emotion['emotion'],
                'mood': mood,
                'confidence': top_emotion['confidence'],
                'all_emotions': emotions,
                'source': 'audio_emotion_detection'
            }
        
        except Exception as e:
            print(f"❌ Error detecting emotion: {e}")
            return {
                'success': False,
                'emotion': 'neutral',
                'mood': 'Calm',
                'confidence': 0,
                'error': str(e)
            }
    
    def detect_emotion_from_base64(self, base64_audio, sample_rate=16000):
        """
        Detect emotion from base64 encoded audio
        
        Args:
            base64_audio: Base64 encoded audio data
            sample_rate: Sample rate of audio
        
        Returns:
            dict: Emotion detection results
        """
        try:
            # Decode base64
            audio_bytes = base64.b64decode(base64_audio)
            
            # Convert to numpy array
            audio_array = np.frombuffer(audio_bytes, dtype=np.int16).astype(np.float32) / 32768.0
            
            return self.detect_emotion(audio_array, sample_rate)
        
        except Exception as e:
            print(f"❌ Error processing base64 audio: {e}")
            return {
                'success': False,
                'emotion': 'neutral',
                'mood': 'Calm',
                'confidence': 0,
                'error': str(e)
            }


def main():
    """Main function for testing"""
    detector = AudioEmotionDetector()
    
    # Test with a sample audio file if provided
    if len(sys.argv) > 1:
        audio_file = sys.argv[1]
        print(f"📁 Loading audio file: {audio_file}")
        
        try:
            audio_data, sr = librosa.load(audio_file, sr=16000)
            result = detector.detect_emotion(audio_data, sr)
            print(json.dumps(result, indent=2))
        except Exception as e:
            print(f"❌ Error: {e}")
    else:
        print("Usage: python audio_emotion_service.py <audio_file>")


if __name__ == '__main__':
    main()
