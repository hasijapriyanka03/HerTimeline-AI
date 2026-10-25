# 🔥 Firebase Configuration

## ⚠️ IMPORTANT: Replace Demo Configuration

The `google-services.json` file in this project is a **DEMO FILE** and will not work for real notifications.

### You MUST Replace It With Your Own

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com
   - Create new project: "Mensa Pregnancy Tracker"

2. **Add Android App**
   - Click Android icon
   - Package name: `com.example.mensa`
   - Download `google-services.json`

3. **Replace Demo File**
   - Replace: `android/app/google-services.json`
   - With your downloaded file

4. **Run App**
   ```bash
   flutter pub get
   flutter run
   ```

## 📚 Documentation

- **Quick Setup (5 min)**: See `../FIREBASE_QUICK_START.md`
- **Complete Guide**: See `../FCM_SETUP_GUIDE.md`

## ✅ Verification

After replacing the file, you should see in console:
```
✅ User granted notification permission
📱 FCM Token: [your-actual-token]
```

## 🚨 Common Issues

**Build fails after adding google-services.json?**
```bash
flutter clean
flutter pub get
flutter run
```

**No FCM token?**
- Verify file is in correct location
- Check file is valid JSON
- Ensure internet connection

---

**Don't forget to replace the demo file! 🔥**
