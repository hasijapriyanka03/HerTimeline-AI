# Privacy Policy Setup for Google Play Store

## Overview
Google Play requires a privacy policy for apps that request sensitive permissions like CAMERA, RECORD_AUDIO, and access to health data.

## Steps to Add Privacy Policy to Play Store

### Option 1: Host Privacy Policy Online (Recommended)

1. **Choose a hosting platform:**
   - GitHub Pages (free)
   - Firebase Hosting (free tier available)
   - Your own website
   - Privacy policy generator services (iubenda, Termly, etc.)

2. **Upload the privacy policy:**
   - Convert `PRIVACY_POLICY.md` to HTML or use a markdown renderer
   - Host it at a permanent URL (e.g., `https://mensahealth.app/privacy`)

3. **Add to Play Store:**
   - Go to Google Play Console
   - Select your app
   - Navigate to: **Store presence** → **App content**
   - Scroll to **Privacy policy**
   - Paste your privacy policy URL
   - Save changes

### Option 2: Use a Privacy Policy Generator

Services like:
- **Termly** (https://termly.io)
- **iubenda** (https://www.iubenda.com)
- **Privacy Policy Generator** (https://www.privacypolicygenerator.info)

These services:
- Generate compliant privacy policies
- Host them for you
- Provide easy updates
- Some offer free tiers

### Option 3: GitHub Pages (Free)

1. Create a GitHub repository: `mensahealth-privacy`
2. Enable GitHub Pages in repository settings
3. Create `index.html` with the privacy policy content
4. Access at: `https://yourusername.github.io/mensahealth-privacy`
5. Add this URL to Play Store

## Privacy Policy Content Checklist

Your privacy policy should address:

- ✅ Camera permission usage
- ✅ Audio/microphone permission usage
- ✅ Health data collection and storage
- ✅ Data security measures
- ✅ Third-party sharing practices
- ✅ User rights (access, deletion, export)
- ✅ Data retention policies
- ✅ Contact information
- ✅ GDPR/CCPA compliance
- ✅ Changes to policy notification

## Permissions Requiring Privacy Policy

Your app requests these sensitive permissions:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**Permissions requiring privacy policy:**
- CAMERA
- RECORD_AUDIO
- Health/fitness data access (if applicable)

## Testing Your Privacy Policy

1. Verify the URL is accessible from any browser
2. Ensure it's not behind a login
3. Check that it loads quickly
4. Verify it's mobile-friendly
5. Test the link in Play Store before submission

## Common Issues

| Issue | Solution |
|-------|----------|
| URL not accessible | Ensure hosting is public and URL is correct |
| Policy too vague | Be specific about data collection and usage |
| Missing contact info | Add email or support contact |
| Not mobile-friendly | Use responsive design or markdown renderer |
| Outdated policy | Update when app features change |

## After Submission

1. Keep privacy policy updated
2. Notify users of significant changes
3. Monitor Play Store feedback for privacy concerns
4. Maintain compliance with regulations
5. Document all data handling practices

## Resources

- [Google Play Console Help - Privacy Policy](https://support.google.com/googleplay/android-developer/answer/10787469)
- [GDPR Compliance Guide](https://gdpr-info.eu/)
- [CCPA Compliance Guide](https://oag.ca.gov/privacy/ccpa)
- [Privacy Policy Template](https://www.termsfeed.com/privacy-policy-template/)

---

**Note**: This is a template. Customize it based on your actual data practices and consult with a legal professional if needed.
