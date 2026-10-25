const admin = require('firebase-admin');
const path = require('path');

class FCMService {
  constructor() {
    // Initialize Firebase Admin if not already initialized
    if (!admin.apps.length) {
      try {
        // Try to use service account key file if available
        const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || 
          path.join(__dirname, '../../firebase-service-account.json');
        const fs = require('fs');
        
        if (fs.existsSync(serviceAccountPath)) {
          const serviceAccount = require(serviceAccountPath);
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: process.env.FIREBASE_PROJECT_ID || 'smensa-c9679',
          });
          console.log('✅ Firebase Admin initialized with service account key');
        } else {
          // Fallback to application default credentials
          admin.initializeApp({
            credential: admin.credential.applicationDefault(),
            projectId: process.env.FIREBASE_PROJECT_ID || 'smensa-c9679',
          });
          console.log('✅ Firebase Admin initialized with default credentials');
        }
      } catch (error) {
        console.error('❌ Firebase Admin initialization error:', error.message);
        console.error('💡 To fix: Download service account key from Firebase Console');
        console.error('   1. Go to Firebase Console > Project Settings > Service Accounts');
        console.error('   2. Click "Generate New Private Key"');
        console.error('   3. Save as firebase-service-account.json in server folder');
      }
    }
  }

  // Send notification to a single device
  async sendToDevice(token, notification, data = {}) {
    try {
      const message = {
        token: token,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'pregnancy_tracker_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('❌ Error sending notification:', error);
      return { success: false, error: error.message };
    }
  }

  // Send notification to multiple devices
  async sendToMultipleDevices(tokens, notification, data = {}) {
    try {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'pregnancy_tracker_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      console.log(`✅ ${response.successCount} notifications sent successfully`);
      console.log(`❌ ${response.failureCount} notifications failed`);
      
      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
    } catch (error) {
      console.error('❌ Error sending notifications:', error);
      return { success: false, error: error.message };
    }
  }

  // Send notification to a topic
  async sendToTopic(topic, notification, data = {}) {
    try {
      const message = {
        topic: topic,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: data,
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'pregnancy_tracker_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log('✅ Topic notification sent successfully:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('❌ Error sending topic notification:', error);
      return { success: false, error: error.message };
    }
  }

  // Subscribe device to topic
  async subscribeToTopic(tokens, topic) {
    try {
      const response = await admin.messaging().subscribeToTopic(tokens, topic);
      console.log(`✅ ${response.successCount} devices subscribed to ${topic}`);
      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error('❌ Error subscribing to topic:', error);
      return { success: false, error: error.message };
    }
  }

  // Unsubscribe device from topic
  async unsubscribeFromTopic(tokens, topic) {
    try {
      const response = await admin.messaging().unsubscribeFromTopic(tokens, topic);
      console.log(`✅ ${response.successCount} devices unsubscribed from ${topic}`);
      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
      };
    } catch (error) {
      console.error('❌ Error unsubscribing from topic:', error);
      return { success: false, error: error.message };
    }
  }
}

module.exports = new FCMService();
