# ⚡ Quick Build Reference - AAB for Play Store

**Mensa v1.0.0 - Fast Track to Play Store**

---

## 🚀 TL;DR - Quick Steps

```bash
# 1. Generate keystore (first time only)
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Create key.properties in mensa/android/
cat > mensa/android/key.properties << EOF
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=~/key.jks
EOF

# 3. Build AAB
cd mensa
flutter clean
flutter pub get
flutter build appbundle --release

# 4. Find your AAB
# Location: mensa/build/app/outputs/bundle/release/app-release.aab

# 5. Upload to Play Store
# Go to: https://play.google.com/console
# Select app → Release → Production → Create new release → Upload AAB
```

---

## 📋 Pre-Build Checklist

- [ ] Flutter installed: `flutter --version`
- [ ] Android SDK installed: `flutter doctor`
- [ ] Java 11+: `java -version`
- [ ] All dependencies: `flutter pub get`
- [ ] App tested: `flutter run`
- [ ] Version updated in `pubspec.yaml`
- [ ] Version code incremented in `android/app/build.gradle`

---

## 🔑 Keystore Setup (One Time)

### Generate Keystore
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**When prompted, enter:**
- Keystore password: `your_secure_password`
- Key password: `your_secure_password` (can be same)
- First and Last Name: `Mensa Developer`
- Organizational Unit: `Development`
- Organization: `Mensa Health`
- City: `San Francisco`
- State: `California`
- Country: `US`

### Create key.properties
```bash
cat > mensa/android/key.properties << EOF
storePassword=your_secure_password
keyPassword=your_secure_password
keyAlias=upload
storeFile=~/key.jks
EOF
```

### Backup Keystore
```bash
cp ~/key.jks ~/Backups/mensa_key.jks
chmod 600 ~/Backups/mensa_key.jks
```

---

## 🏗️ Build AAB

### Standard Build
```bash
cd mensa
flutter clean
flutter pub get
flutter build appbundle --release
```

### Build with Obfuscation (Recommended)
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Output
```
✓ Built build/app/outputs/bundle/release/app-release.aab (16.2 MB).
```

---

## ✅ Verify AAB

```bash
# Check file exists
ls -lh mensa/build/app/outputs/bundle/release/app-release.aab

# Verify signing
jarsigner -verify -verbose mensa/build/app/outputs/bundle/release/app-release.aab

# Expected: jar verified.
```

---

## 📤 Upload to Play Store

1. Go to: https://play.google.com/console
2. Sign in with your Google account
3. Select "Mensa - Women's Health Companion"
4. Click "Release" → "Production"
5. Click "Create new release"
6. Click "Browse files" in AAB section
7. Select: `mensa/build/app/outputs/bundle/release/app-release.aab`
8. Click "Upload"
9. Fill in release notes
10. Click "Review release"
11. Click "Start rollout to Production"

---

## 🔄 Update Process (For Future Releases)

### Increment Version
```bash
# In pubspec.yaml
version: 1.0.1+2

# In android/app/build.gradle
versionCode 2
versionName "1.0.1"
```

### Build New AAB
```bash
cd mensa