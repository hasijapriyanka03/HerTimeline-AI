# 📦 Build & Sign AAB for Google Play Store

**Complete Guide for Mensa v1.0.0**

---

## 📋 Prerequisites

Before building the AAB, ensure you have:

- ✅ Flutter SDK installed and updated
- ✅ Android SDK installed
- ✅ Java Development Kit (JDK) 11 or higher
- ✅ Git installed
- ✅ All dependencies installed (`flutter pub get`)
- ✅ App tested thoroughly on multiple devices

### Check Your Setup

```bash
# Check Flutter version
flutter --version

# Check Android SDK
flutter doctor

# Check Java version
java -version
```

---

## 🔑 Step 1: Create a Keystore File

### What is a Keystore?
A keystore is a file that contains your app's signing key. You'll use this to sign your AAB for Play Store.

### Generate Keystore (First Time Only)

```bash
# Navigate to your project directory
cd mensa

# Generate keystore file
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# You'll be prompted for:
# - Keystore password (remember this!)
# - Key password (can be same as keystore)
# - First and Last Name
# - Organizational Unit
# - Organization
# - City/Locality
# - State/Province
# - Country Code (2 letters)
```

### Example Output
```
Enter keystore password: ••••••••
Re-enter new password: ••••••••
What is your first and last name?
  [Unknown]:  Mensa Developer
What is the name of your organizational unit?
  [Unknown]:  Development
What is the name of your organization?
  [Unknown]:  Mensa Health
What is the name of your City or Locality?
  [Unknown]:  San Francisco
What is the name of your State or Province?
  [Unknown]:  California
What is the two-letter country code for this unit?
  [Unknown]:  US
Is CN=Mensa Developer, OU=Development, O=Mensa Health, L=San Francisco, ST=California, C=US correct?
  [no]:  yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
	for: CN=Mensa Developer, OU=Development, O=Mensa Health, L=San Francisco, ST=California, C=US
[Storing ~/key.jks]
```

### ⚠️ Important: Backup Your Keystore
```bash
# Copy keystore to a safe location
cp ~/key.jks ~/Backups/mensa_key.jks

# Also save the keystore information
# Store password, key alias, and key password in a secure location
```

---

## 🔐 Step 2: Configure Signing in Flutter

### Create or Update `android/key.properties`

```bash
# Navigate to android directory
cd mensa/android

# Create key.properties file
cat > key.properties << EOF
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=~/key.jks
EOF
```

### Update `android/app/build.gradle`

```gradle
// Add this before the android block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing configuration ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 📦 Step 3: Update App Version

### Update `pubspec.yaml`

```yaml
version: 1.0.0+1

# Where:
# 1.0.0 = version name (shown to users)
# +1 = version code (internal, must increment for each release)
```

### Update `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.mensa.health"
        minSdkVersion 26
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

---

## 🏗️ Step 4: Build the AAB

### Clean Previous Builds

```bash
# Navigate to project root
cd mensa

# Clean build files
flutter clean

# Get dependencies
flutter pub get
```

### Build AAB (Recommended for Play Store)

```bash
# Build release AAB
flutter build appbundle --release

# Output location:
# mensa/build/app/outputs/bundle/release/app-release.aab
```

### Alternative: Build APK (for testing)

```bash
# Build release APK
flutter build apk --release

# Output location:
# mensa/build/app/outputs/apk/release/app-release.apk
```

### Build Output

```
✓ Built build/app/outputs/bundle/release/app-release.aab (16.2 MB).
```

---

## ✅ Step 5: Verify the AAB

### Check AAB File

```bash
# Navigate to build output
cd mensa/build/app/outputs/bundle/release/

# List files
ls -lh app-release.aab

# Expected output:
# -rw-r--r--  1 user  group  16.2M Dec 20 10:30 app-release.aab
```

### Verify Signing

```bash
# Check if AAB is properly signed
jarsigner -verify -verbose -certs app-release.aab

# Expected output:
# jar verified.
```

### Analyze AAB (Optional)

```bash
# Use bundletool to analyze
bundletool validate --bundle=app-release.aab

# Or get bundle info
bundletool dump manifest --bundle=app-release.aab
```

---

## 📤 Step 6: Upload to Google Play Console

### Prepare for Upload

1. **Log in to Google Play Console**
   - Go to https://play.google.com/console
   - Sign in with your Google account

2. **Select Your App**
   - Click on "Mensa - Women's Health Companion"
   - Go to "Release" → "Production"

3. **Create New Release**
   - Click "Create new release"
   - You'll see the upload section

### Upload AAB

```bash
# Option 1: Upload via Web Console
# 1. Click "Browse files" in the AAB section
# 2. Select: mensa/build/app/outputs/bundle/release/app-release.aab
# 3. Click "Upload"

# Option 2: Upload via Command Line (if using Play Console API)
# This requires additional setup with service account
```

### Fill in Release Details

1. **Release Name**
   - Enter: "Mensa v1.0.0 - Initial Release"

2. **Release Notes**
   - Add release notes (see RELEASE_NOTES.md)
   - Highlight key features

3. **Rollout Percentage**
   - Start with 5-10% for staged rollout
   - Or go to 100% for full release

4. **Review & Confirm**
   - Review all information
   - Click "Review release"
   - Click "Start rollout to Production"

---

## 🔍 Step 7: Monitor Review & Rollout

### Check Review Status

1. **Go to Release Dashboard**
   - Navigate to "Release" → "Production"
   - Check "Release overview"

2. **Monitor Status**
   - "In review" (2-3 hours to 7 days)
   - "Approved" (app is live)
   - "Rejected" (fix issues and resubmit)

3. **Check for Issues**
   - Look for rejection reasons
   - Review policy violations
   - Address any concerns

### Monitor Rollout

1. **Check Rollout Progress**
   - See percentage of users receiving update
   - Monitor crash rates
   - Check user reviews

2. **Pause or Halt Rollout**
   - If issues found, pause rollout
   - Fix issues
   - Resume or resubmit

---

## 🐛 Troubleshooting

### Issue: "Keystore not found"

```bash
# Solution: Check keystore path
ls -la ~/key.jks

# If not found, regenerate:
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Issue: "Wrong password"

```bash
# Solution: Verify password in key.properties
cat mensa/android/key.properties

# If wrong, update with correct password
```

### Issue: "Build fails with signing error"

```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build appbundle --release
```

### Issue: "AAB too large"

```bash
# Solution: Enable minification and shrinking
# Already configured in build.gradle with:
# minifyEnabled true
# shrinkResources true

# Or manually optimize:
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Issue: "Upload fails in Play Console"

```bash
# Solution: Verify AAB integrity
jarsigner -verify -verbose app-release.aab

# Check file size (should be < 100 MB for initial upload)
ls -lh app-release.aab

# Try uploading again or contact Google Play Support
```

---

## 📋 Checklist Before Upload

- [ ] AAB file generated successfully
- [ ] AAB file is properly signed
- [ ] Version code incremented
- [ ] Version name updated
- [ ] App tested on multiple devices
- [ ] No crashes or errors
- [ ] All features working
- [ ] Release notes prepared
- [ ] Screenshots prepared
- [ ] Privacy policy published
- [ ] Terms of service published
- [ ] Support email verified
- [ ] Google Play Console account ready
- [ ] App listing complete
- [ ] Content rating set
- [ ] Pricing set to Free

---

## 🚀 Quick Build Commands

### One-Line Build

```bash
cd mensa && flutter clean && flutter pub get && flutter build appbundle --release
```

### Build with Obfuscation

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Build APK for Testing

```bash
flutter build apk --release
```

### Build Multiple APKs (for different architectures)

```bash
flutter build apk --release --split-per-abi
```

---

## 📊 Build Output Locations

```
mensa/
├── build/
│   └── app/
│       └── outputs/
│           ├── bundle/
│           │   └── release/
│           │       └── app-release.aab          ← Upload this to Play Store
│           └── apk/
│               └── release/
│                   ├── app-release.apk          ← For testing
│                   ├── app-armeabi-v7a-release.apk
│                   ├── app-arm64-v8a-release.apk
│                   └── app-x86_64-release.apk
```

---

## 🔐 Security Best Practices

### Protect Your Keystore

```bash
# Set restrictive permissions
chmod 600 ~/key.jks

# Backup to secure location
cp ~/key.jks ~/Backups/mensa_key.jks
chmod 600 ~/Backups/mensa_key.jks

# Never commit to version control
echo "key.jks" >> .gitignore
echo "key.properties" >> .gitignore
```

### Protect Your Passwords

```bash
# Store passwords securely
# Option 1: Use environment variables
export KEYSTORE_PASSWORD="your_password"
export KEY_PASSWORD="your_password"

# Option 2: Use password manager
# Option 3: Use secure file storage

# Never hardcode passwords in files
# Never share passwords via email or chat
```

### Backup Strategy

```bash
# Create backup directory
mkdir -p ~/Backups/Mensa

# Backup keystore
cp ~/key.jks ~/Backups/Mensa/key.jks

# Backup key.properties (without passwords)
cp mensa/android/key.properties ~/Backups/Mensa/key.properties.backup

# Backup to cloud storage (encrypted)
# Use: Google Drive, Dropbox, OneDrive, etc.
```

---

## 📚 Additional Resources

### Official Documentation
- [Flutter Build Documentation](https://flutter.dev/docs/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)

### Tools
- [Bundletool](https://developer.android.com/studio/command-line/bundletool)
- [Android Studio](https://developer.android.com/studio)
- [Android SDK Manager](https://developer.android.com/studio/command-line/sdkmanager)

### Troubleshooting
- [Flutter Issues](https://github.com/flutter/flutter/issues)
- [Stack Overflow - Flutter Tag](https://stackoverflow.com/questions/tagged/flutter)
- [Google Play Console Community](https://support.google.com/googleplay/android-developer/community)

---

## ✅ Final Verification

Before submitting to Play Store:

```bash
# 1. Verify AAB exists
ls -lh mensa/build/app/outputs/bundle/release/app-release.aab

# 2. Verify signing
jarsigner -verify -verbose mensa/build/app/outputs/bundle/release/app-release.aab

# 3. Check version
grep "version:" mensa/pubspec.yaml

# 4. Verify app works
flutter run --release

# 5. Check file size
du -h mensa/build/app/outputs/bundle/release/app-release.aab
```

---

## 🎉 You're Ready!

Your AAB is now ready for Google Play Store submission!

**Next Steps:**
1. Log in to Google Play Console
2. Go to your app
3. Click "Release" → "Production"
4. Click "Create new release"
5. Upload the AAB file
6. Fill in release details
7. Review and submit
8. Monitor review status
9. Celebrate your launch! 🎊

---

## 📞 Support

If you encounter issues:

1. Check this guide again
2. Review Flutter documentation
3. Check Google Play Console help
4. Search Stack Overflow
5. Contact Google Play Support

---

**Last Updated**: December 20, 2025  
**Version**: 1.0.0  
**Status**: ✅ Ready for Play Store

