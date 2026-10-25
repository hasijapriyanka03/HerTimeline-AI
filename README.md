# 🌸 Mensa - Women's Health Companion

> **Your Personal Health Journey, Completely Private & Judgment-Free**

A comprehensive Flutter mobile application designed to empower women by providing personalized health tracking, AI-powered insights, and supportive wellness features across menstruation, pregnancy, and menopause.

---

## ✨ Key Features

### 📊 Multi-Tracker Support
- **Menstruation Tracking**: Log flow, symptoms, moods, and cycle patterns
- **Pregnancy Tracking**: Monitor weekly progress, symptoms, and health metrics
- **Menopause Tracking**: Track symptoms and wellness during menopause transition

### 🤖 AI-Powered Intelligence
- **Gemini AI Integration**: Personalized health insights based on your logs
- **Agora Conversational AI**: Voice-based health companion with two modes:
  - 📚 **Education Mode**: Learn about health topics
  - 💬 **Ranting Mode**: Emotional support and venting space
- **Personalized Notifications**: Smart reminders based on your cycle phase
- **Period Reminders**: Cute, loving messages generated from your health data

### 💬 Smart Communication
- **WhatsApp Integration**: Receive health reminders via WhatsApp using Twilio
- **Local Notifications**: Instant in-app alerts
- **FCM Support**: Firebase Cloud Messaging for push notifications

### 🎯 Gamification & Rewards
- **Daily Streak System**: Track consecutive days of logging
- **Wallet Points**: Earn points for consistent tracking
- **Voucher System**: Redeem points for rewards
- **Achievement Badges**: Celebrate milestones

### � vPersonalization
- **Theme Support**: Light/Dark mode with multiple color schemes
- **Multi-Language**: English and Hindi support
- **Customizable Trackers**: Choose your primary health tracker

### 🔐 Privacy & Security
- **End-to-End Encryption**: Your data stays private
- **No Judgment Policy**: Safe space for health tracking
- **Data Ownership**: Complete control over your information
- **Permanent Deletion**: One-tap account deletion with all data removal

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Node.js 16+
- Firebase account
- Twilio account (for WhatsApp)
- Google Gemini API key
- Agora account (for voice features)

### Installation

#### Backend Setup
```bash
cd server
npm install
cp .env.example .env
# Update .env with your credentials
npm start
```

#### Frontend Setup
```bash
cd mensa
flutter pub get
flutter run
```

---

## 📱 App Structure

### Screens

#### Onboarding
- **Three Beautiful Slides**:
  1. 👂 "We Listen and We don't Judge"
  2. 🤝 "Your secrets stays yours, pinky promise"
  3. 💜 "We embrace the Way You are!"
- Smooth page transitions with dot indicators
- Skip option for returning users

#### Authentication
- **Login/Sign Up**: Secure user authentication
- **Tracker Selection**: Choose primary health tracker
- **Profile Setup**: Initial health information

#### Main Dashboard
- **Cycle Overview**: Current day and phase information
- **Quick Actions**: Fast access to logging and features
- **Streak Widget**: Visual streak counter
- **Wallet Display**: Points and rewards

#### Tracker Screens
- **Menstruation Home**: Cycle tracking with predictions
- **Pregnancy Home**: Weekly progress and health metrics
- **Menopause Home**: Symptom tracking and support

#### Features
- **AI Chat**: Talk to health companion
- **Ranting AI**: Emotional support voice agent
- **Cycle History**: View past logs and patterns
- **Wallet**: View and manage points
- **Vouchers**: Browse and redeem rewards
- **Profile**: Manage personal information
- **Settings**: Theme, language, and preferences

#### Profile Management
- **Personal Information**: Name, age, height, weight
- **Health Data**: Blood type, medical conditions, allergies
- **Emergency Contacts**: Important contact information
- **WhatsApp Notifications**: Phone number for SMS/WhatsApp
- **Account Settings**: Theme, language, notifications
- **Permanent Delete**: One-tap account deletion

---

## 🔧 Core Features Implementation

### 1. Health Tracking System

#### Menstruation Logging
```dart
// Log menstruation data
await apiService.addMenstruationLog({
  'user_id': userId,
  'date': DateTime.now().toIso8601String(),
  'flow_level': 'Medium',
  'symptoms': ['Cramps', 'Fatigue'],
  'moods': ['Tired', 'Calm'],
});
```

#### Automatic Streak Check-in
- Triggered on log creation
- Tracks consecutive days of logging
- Awards wallet points

### 2. AI Integration

#### Gemini Personalized Notifications
```dart
// Generate personalized notification
final notification = await apiService.generatePersonalizedNotification(
  userId: userId,
  tracker: 'menstruation',
  cycleDay: 5,
);
```

#### Period Reminders
```dart
// Generate cute period reminder
final reminder = await apiService.generatePeriodReminder(
  userId: userId,
  daysUntil: 3,
);
```

#### Agora Voice Agent
```dart
// Start voice conversation
await apiService.startAgoraAgent(
  channelName: 'health_chat_$userId',
  agentName: 'Mensa Health Companion',
  mode: 'ranting', // or 'education'
);
```

### 3. Notification System

#### WhatsApp Notifications
```dart
// Send WhatsApp notification
await apiService.sendNotification(
  userId: userId,
  phoneNumber: '+1234567890',
  title: '🌸 Period Reminder',
  body: 'Your period is coming in 3 days!',
  sendWhatsApp: true,
);
```

#### Multi-Channel Support
- WhatsApp (Twilio)
- Local Notifications
- Firebase Cloud Messaging (FCM)

### 4. Gamification System

#### Wallet Points
```dart
// Add wallet points
await apiService.addWalletPoints(
  userId,
  amount: 10,
  reason: 'Daily log',
  category: 'menstruation',
);
```

#### Voucher Redemption
```dart
// Redeem voucher
await apiService.redeemVoucher(
  userId: userId,
  voucherId: voucherId,
  pointsUsed: 100,
);
```

### 5. Account Management

#### Permanent Account Deletion
```dart
// Delete all user data
final success = await apiService.deleteUserAccount(userId);
```

Deletes:
- User profile
- All health logs
- Wallet data
- Streaks
- Vouchers
- Appointments
- All personal information

---

## 🏗️ Architecture

### Backend (Node.js + Express)
```
server/
├── src/
│   ├── routes/
│   │   ├── menstruation.routes.js
│   │   ├── pregnancy.routes.js
│   │   ├── menopause.routes.js
│   │   ├── notifications.routes.js
│   │   ├── wallet.routes.js
│   │   ├── streak.routes.js
│   │   └── userProfile.routes.js
│   ├── services/
│   │   ├── database.js
│   │   ├── geminiNotificationService.js
│   │   ├── periodReminderService.js
│   │   ├── twilioWhatsappService.js
│   │   └── unifiedNotificationService.js
│   └── app.js
└── data/
    └── db.json
```

### Frontend (Flutter)
```
mensa/
├── lib/
│   ├── screens/
│   │   ├── onboarding_screen.dart
│   │   ├── auth/
│   │   ├── menstruation/
│   │   ├── pregnancy/
│   │   ├── menopause/
│   │   ├── profile_screen.dart
│   │   └── ...
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── notification_service.dart
│   │   └── ...
│   ├── widgets/
│   │   ├── streak_widget.dart
│   │   └── ...
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   └── localization_provider.dart
│   └── main.dart
```

---

## 🔌 API Endpoints

### User Management
```
POST   /api/user/:userId/profile          - Save user profile
GET    /api/user/:userId/profile          - Get user profile
POST   /api/user/:userId/phone-number     - Update phone number
GET    /api/user/:userId/phone-number     - Get phone number
DELETE /api/user/:userId/account          - Delete account permanently
```

### Health Tracking
```
POST   /api/menstruation/:userId/log      - Log menstruation
GET    /api/menstruation/:userId/logs     - Get menstruation logs
GET    /api/menstruation/:userId/predictions - Get cycle predictions

POST   /api/pregnancy/:userId/log         - Log pregnancy data
GET    /api/pregnancy/:userId/logs        - Get pregnancy logs

POST   /api/menopause/:userId/log         - Log menopause data
GET    /api/menopause/:userId/logs        - Get menopause logs
```

### Notifications
```
POST   /api/notifications/send                    - Send notification
POST   /api/notifications/generate-personalized   - Generate AI notification
POST   /api/notifications/period-reminder-ai      - Generate period reminder
POST   /api/notifications/streak-reminder         - Send streak reminder
```

### Gamification
```
GET    /api/wallet/:userId                - Get wallet info
POST   /api/wallet/:userId/add-points     - Add points
GET    /api/wallet/:userId/history        - Get transaction history

GET    /api/streak/:userId/:category      - Get streak info
POST   /api/streak/:userId/:category/check-in - Check in streak

GET    /api/voucher/available             - Get available vouchers
POST   /api/voucher/:userId/redeem        - Redeem voucher
```

---

## 🎨 Design System

### Color Palette
- **Primary Pink**: `#E8C4C4` - Menstruation
- **Primary Purple**: `#D4C4E8` - Pregnancy
- **Primary Teal**: `#B8D4C8` - Menopause
- **Accent Green**: `#B8D4C8` - Success
- **Background**: `#FAF5F5` - Light background

### Typography
- **Headlines**: Bold, 24-28px
- **Body**: Regular, 14-16px
- **Captions**: Light, 12-13px

### Components
- Rounded corners (12-24px border radius)
- Soft shadows for depth
- Gradient backgrounds
- Smooth animations

---

## 🔐 Security Features

### Data Protection
- ✅ End-to-end encryption
- ✅ Secure API endpoints
- ✅ Firebase authentication
- ✅ Phone number validation
- ✅ CORS protection

### Privacy
- ✅ No third-party data sharing
- ✅ Local data caching
- ✅ Secure token storage
- ✅ One-tap account deletion
- ✅ Complete data removal

---

## 📊 Database Schema

### Collections
- **users**: User accounts and phone numbers
- **userProfiles**: Detailed user information
- **menstruationLogs**: Menstruation tracking data
- **pregnancyLogs**: Pregnancy tracking data
- **menopauseLogs**: Menopause tracking data
- **userWallets**: Points and rewards
- **streaks**: Tracking streaks
- **userVouchers**: Redeemed vouchers
- **appointments**: Medical appointments
- **fcmTokens**: Push notification tokens

---

## 🚀 Deployment

### Backend Deployment
```bash
# Using Render or Heroku
npm install
npm start

# Environment variables required:
# - PORT
# - GEMINI_API_KEY
# - TWILIO_ACCOUNT_SID
# - TWILIO_AUTH_TOKEN
# - FIREBASE_PROJECT_ID
# - AGORA_APP_ID
# - AGORA_APP_CERTIFICATE
```

### Frontend Deployment
```bash
# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

---

## 📚 Documentation

- [Onboarding Implementation](./ONBOARDING_SCREEN_IMPLEMENTATION.md)
- [Period Reminder Feature](./PERIOD_REMINDER_IMPLEMENTATION_COMPLETE.md)
- [Delete Account Feature](./DELETE_ACCOUNT_IMPLEMENTATION.md)
- [Streak System](./README_STREAK_SYSTEM.md)
- [Wallet & Vouchers](./STREAK_WALLET_SYSTEM.md)

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 💬 Support

For support, email support@mensa-health.com or open an issue on GitHub.

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for backend services
- **Google Gemini** for AI capabilities
- **Twilio** for WhatsApp integration
- **Agora** for voice features
- **Our Users** for their trust and feedback

---

## 🌟 Features Roadmap

### Coming Soon
- [ ] Wearable device integration
- [ ] Advanced analytics dashboard
- [ ] Community features
- [ ] Doctor consultation booking
- [ ] Medication reminders
- [ ] Nutrition tracking
- [ ] Exercise recommendations
- [ ] Sleep tracking
- [ ] Mood journal with AI analysis
- [ ] Family sharing features

---

## 📞 Contact

- **Website**: www.mensa-health.com
- **Email**: hello@mensa-health.com
- **Twitter**: @MensaHealth
- **Instagram**: @MensaHealth

---

<div align="center">

### Made with 💜 for Women's Health

**Mensa - Your Personal Health Journey, Completely Private & Judgment-Free**

[⬆ back to top](#-mensa---womens-health-companion)

</div>
