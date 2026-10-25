class AppStrings {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      // Common
      'app_name': 'Mensa',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'back': 'Back',
      'next': 'Next',
      'skip': 'Skip',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'no_data': 'No data available',

      // Profile
      'profile': 'Profile',
      'my_profile': 'My Profile',
      'settings': 'Settings',
      'logout': 'Logout',
      'logout_restart': 'Logout & Restart',
      'edit_profile': 'Edit Profile',
      'save_profile': 'Save Profile',
      'profile_saved': 'Profile saved successfully! 💜',
      'failed_save_profile': 'Failed to save profile. Please try again.',

      // Settings
      'app_settings': 'App Settings',
      'theme': 'Theme',
      'language': 'Language',
      'color_scheme': 'Color Scheme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'english': 'English',
      'hindi': 'हिंदी',
      'theme_changed': 'Theme changed successfully',
      'language_changed': 'Language changed successfully',
      'color_purple': 'Purple',
      'color_rose': 'Rose',
      'color_teal': 'Teal',
      'color_amber': 'Amber',
      'color_indigo': 'Indigo',

      // Basic Information
      'basic_information': 'Basic Information',
      'full_name': 'Full Name',
      'age': 'Age',
      'height': 'Height (cm)',
      'weight': 'Weight (kg)',
      'blood_type': 'Blood Type',
      'bmi': 'BMI',

      // Medical Information
      'medical_information': 'Medical Information',
      'medical_conditions': 'Medical Conditions',
      'allergies': 'Allergies',
      'current_medications': 'Current Medications',
      'add': 'Add',

      // Emergency Contact
      'emergency_contact': 'Emergency Contact',
      'contact_name': 'Contact Name',
      'phone_number': 'Phone Number',
      'email_address': 'Email Address',
      'send_emergency_alert': 'Send Emergency Alert',
      'emergency_alert': 'Emergency Alert',

      // Medical Report OCR
      'medical_report_analysis': 'Medical Report Analysis',
      'upload_medical_report': 'Upload Medical Report',
      'upload_report_image': 'Upload Report Image',
      'take_photo': 'Take Photo',
      'choose_image': 'Choose Image',
      'upload_pdf': 'Upload PDF',
      'analyzing': 'Analyzing...',
      'report_analyzed': '✅ Medical report analyzed successfully!',
      'failed_analyze': '❌ Failed to analyze report. Please try again.',
      'pdf_analyzed': '✅ PDF report analyzed successfully!',
      'failed_analyze_pdf': '❌ Failed to analyze PDF. Please try again.',
      'analysis_result': 'Analysis Result',
      'key_findings': 'Key Findings:',
      'recommendations': 'Recommendations:',

      // Tracker
      'active_tracker': 'Active Tracker',
      'current_tracker': 'Current Tracker',
      'pregnancy': 'Pregnancy',
      'menstruation': 'Menstruation',
      'menopause': 'Menopause',
      'switching_to': 'Switching to',
      'tracker_changed': 'Tracker changed successfully',

      // Dashboard
      'dashboard': 'Dashboard',
      'home': 'Home',
      'today': 'Today',
      'this_week': 'This Week',
      'this_month': 'This Month',

      // Logs
      'logs': 'Logs',
      'daily_log': 'Daily Log',
      'add_log': 'Add Log',
      'edit_log': 'Edit Log',
      'delete_log': 'Delete Log',
      'log_saved': 'Log saved successfully',
      'log_deleted': 'Log deleted successfully',

      // Cycle
      'cycle': 'Cycle',
      'cycle_calendar': 'Cycle Calendar',
      'cycle_history': 'Cycle History',
      'cycle_insights': 'Cycle Insights',
      'next_period': 'Next Period',
      'cycle_length': 'Cycle Length',
      'period_length': 'Period Length',
      'last_period': 'Last Period',

      // Pregnancy
      'pregnancy_tracker': 'Pregnancy Tracker',
      'due_date': 'Due Date',
      'weeks_pregnant': 'Weeks Pregnant',
      'trimester': 'Trimester',
      'appointments': 'Appointments',
      'checklist': 'Checklist',
      'pregnancy_setup': 'Pregnancy Setup',

      // Menopause
      'menopause_tracker': 'Menopause Tracker',
      'symptoms': 'Symptoms',
      'symptom_log': 'Symptom Log',
      'hot_flashes': 'Hot Flashes',
      'night_sweats': 'Night Sweats',
      'mood_changes': 'Mood Changes',

      // AI Chat
      'ai_chat': 'AI Chat',
      'educate_me': 'Educate Me',
      'ask_question': 'Ask a question...',
      'send': 'Send',
      'type_message': 'Type your message...',

      // Nutrition
      'nutrition': 'Nutrition',
      'water_intake': 'Water Intake',
      'meals': 'Meals',
      'add_meal': 'Add Meal',

      // Breathing
      'breathing_exercise': 'Breathing Exercise',
      'start_exercise': 'Start Exercise',
      'inhale': 'Inhale',
      'hold': 'Hold',
      'exhale': 'Exhale',

      // Appointments
      'appointment': 'Appointment',
      'add_appointment': 'Add Appointment',
      'appointment_date': 'Appointment Date',
      'appointment_time': 'Appointment Time',
      'doctor_name': 'Doctor Name',
      'clinic_name': 'Clinic Name',

      // Validation
      'please_enter': 'Please enter',
      'please_select': 'Please select',
      'invalid_email': 'Invalid email',
      'required_field': 'This field is required',

      // Reset & Restart
      'reset_restart': 'Reset & Restart',
      'clear_all_data':
          'Clear all app data and restart with fresh setup. This will log you out and reset all trackers.',
      'logout_confirm': 'Are you sure you want to continue?',
      'logging_out': 'Logging out...',
      'data_cleared': 'All data cleared. Returning to login...',

      // Educate Me
      'learn_about': 'Learn about periods, menopause & pregnancy',

      // Report
      'report': 'Report',
      'print_report': 'Print Report',
      'export_pdf': 'Export as PDF',
      'share_report': 'Share Report',

      // Onboarding
      'welcome': 'Welcome',
      'get_started': 'Get Started',
      'select_tracker': 'Select Your Tracker',
      'setup_profile': 'Setup Your Profile',
      'complete_setup': 'Complete Setup',

      // Errors
      'network_error': 'Network error. Please check your connection.',
      'server_error': 'Server error. Please try again later.',
      'something_wrong': 'Something went wrong. Please try again.',

      // Additional UI Strings
      'your_profile': 'Your Profile',
      'changing_tracker_info':
          'Changing tracker will switch your home screen. Your data is preserved.',
      'upload_medical_report_desc':
          'Upload an image of your medical report and our AI will analyze it and provide an easy-to-understand summary.',
      'error_saving_profile': 'Error saving profile. Please try again.',
      'day': 'Day',
      'luteal_phase': 'Luteal Phase',
      'menstrual_phase': 'Menstrual Phase',
      'follicular_phase': 'Follicular Phase',
      'ovulation_phase': 'Ovulation Phase',
      'tomorrow': 'Tomorrow',
      'avg_cycle': 'Avg Cycle',
      'days': 'days',
      'pcos_tracking': 'PCOS Tracking',
      'specialized_tracking_pcos': 'Specialized tracking for PCOS',
      'log_today': 'Log Today',
      'flow_level': 'Flow Level',
      'light': 'Light',
      'medium': 'Medium',
      'heavy': 'Heavy',
      'spotting': 'Spotting',
      'none': 'None',
      'how_are_you_feeling': 'How are you feeling?',
      'managing_wellness': 'Managing your wellness journey',
      'days_tracked': 'Days Tracked',
      'avg_symptoms': 'Avg Symptoms',
      'per_day': '/day',
      'understanding_menopause': 'Understanding Menopause',
      'normal_symptoms': 'Normal Symptoms',
      'when_to_see_doctor': 'When to See a Doctor',
      'good_morning': 'Good Morning! 💜',
      'your_profile_text': 'Your Profile',
      'bmi_category': 'BMI',
      'invalid_age': 'Please enter a valid age',
      'invalid_height': 'Invalid height',
      'invalid_weight': 'Invalid weight',
      'no_summary_available': 'No summary available',
    },
    'hi': {
      // Common
      'app_name': 'मेंसा',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'back': 'वापस',
      'next': 'अगला',
      'skip': 'छोड़ें',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफल',
      'warning': 'चेतावनी',
      'no_data': 'कोई डेटा उपलब्ध नहीं',

      // Profile
      'profile': 'प्रोफाइल',
      'my_profile': 'मेरी प्रोफाइल',
      'settings': 'सेटिंग्स',
      'logout': 'लॉगआउट',
      'logout_restart': 'लॉगआउट और पुनः शुरू करें',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'save_profile': 'प्रोफाइल सहेजें',
      'profile_saved': 'प्रोफाइल सफलतापूर्वक सहेजा गया! 💜',
      'failed_save_profile':
          'प्रोफाइल सहेजने में विफल। कृपया पुनः प्रयास करें।',

      // Settings
      'app_settings': 'ऐप सेटिंग्स',
      'theme': 'थीम',
      'language': 'भाषा',
      'color_scheme': 'रंग योजना',
      'light_mode': 'लाइट मोड',
      'dark_mode': 'डार्क मोड',
      'english': 'English',
      'hindi': 'हिंदी',
      'theme_changed': 'थीम सफलतापूर्वक बदल दी गई',
      'language_changed': 'भाषा सफलतापूर्वक बदल दी गई',
      'color_purple': 'बैंगनी',
      'color_rose': 'गुलाब',
      'color_teal': 'नीलम',
      'color_amber': 'पीला',
      'color_indigo': 'नीला',

      // Basic Information
      'basic_information': 'बुनियादी जानकारी',
      'full_name': 'पूरा नाम',
      'age': 'आयु',
      'height': 'ऊंचाई (सेमी)',
      'weight': 'वजन (किग्रा)',
      'blood_type': 'रक्त प्रकार',
      'bmi': 'बीएमआई',

      // Medical Information
      'medical_information': 'चिकित्सा जानकारी',
      'medical_conditions': 'चिकित्सा स्थितियां',
      'allergies': 'एलर्जी',
      'current_medications': 'वर्तमान दवाएं',
      'add': 'जोड़ें',

      // Emergency Contact
      'emergency_contact': 'आपातकालीन संपर्क',
      'contact_name': 'संपर्क का नाम',
      'phone_number': 'फोन नंबर',
      'email_address': 'ईमेल पता',
      'send_emergency_alert': 'आपातकालीन सतर्कता भेजें',
      'emergency_alert': 'आपातकालीन सतर्कता',

      // Medical Report OCR
      'medical_report_analysis': 'चिकित्सा रिपोर्ट विश्लेषण',
      'upload_medical_report': 'चिकित्सा रिपोर्ट अपलोड करें',
      'upload_report_image': 'रिपोर्ट छवि अपलोड करें',
      'take_photo': 'फोटो लें',
      'choose_image': 'छवि चुनें',
      'upload_pdf': 'पीडीएफ अपलोड करें',
      'analyzing': 'विश्लेषण जारी है...',
      'report_analyzed': '✅ चिकित्सा रिपोर्ट सफलतापूर्वक विश्लेषण की गई!',
      'failed_analyze':
          '❌ रिपोर्ट का विश्लेषण करने में विफल। कृपया पुनः प्रयास करें।',
      'pdf_analyzed': '✅ पीडीएफ रिपोर्ट सफलतापूर्वक विश्लेषण की गई!',
      'failed_analyze_pdf':
          '❌ पीडीएफ का विश्लेषण करने में विफल। कृपया पुनः प्रयास करें।',
      'analysis_result': 'विश्लेषण परिणाम',
      'key_findings': 'मुख्य निष्कर्ष:',
      'recommendations': 'सिफारिशें:',

      // Tracker
      'active_tracker': 'सक्रिय ट्रैकर',
      'current_tracker': 'वर्तमान ट्रैकर',
      'pregnancy': 'गर्भावस्था',
      'menstruation': 'मासिक धर्म',
      'menopause': 'रजोनिवृत्ति',
      'switching_to': 'को स्विच कर रहे हैं',
      'tracker_changed': 'ट्रैकर सफलतापूर्वक बदल दिया गया',

      // Dashboard
      'dashboard': 'डैशबोर्ड',
      'home': 'होम',
      'today': 'आज',
      'this_week': 'इस सप्ताह',
      'this_month': 'इस महीने',

      // Logs
      'logs': 'लॉग्स',
      'daily_log': 'दैनिक लॉग',
      'add_log': 'लॉग जोड़ें',
      'edit_log': 'लॉग संपादित करें',
      'delete_log': 'लॉग हटाएं',
      'log_saved': 'लॉग सफलतापूर्वक सहेजा गया',
      'log_deleted': 'लॉग सफलतापूर्वक हटाया गया',

      // Cycle
      'cycle': 'चक्र',
      'cycle_calendar': 'चक्र कैलेंडर',
      'cycle_history': 'चक्र इतिहास',
      'cycle_insights': 'चक्र अंतर्दृष्टि',
      'next_period': 'अगली अवधि',
      'cycle_length': 'चक्र की लंबाई',
      'period_length': 'अवधि की लंबाई',
      'last_period': 'अंतिम अवधि',

      // Pregnancy
      'pregnancy_tracker': 'गर्भावस्था ट्रैकर',
      'due_date': 'नियत तारीख',
      'weeks_pregnant': 'गर्भावस्था के सप्ताह',
      'trimester': 'तिमाही',
      'appointments': 'नियुक्तियां',
      'checklist': 'चेकलिस्ट',
      'pregnancy_setup': 'गर्भावस्था सेटअप',

      // Menopause
      'menopause_tracker': 'रजोनिवृत्ति ट्रैकर',
      'symptoms': 'लक्षण',
      'symptom_log': 'लक्षण लॉग',
      'hot_flashes': 'गर्म चमक',
      'night_sweats': 'रात को पसीना आना',
      'mood_changes': 'मनोदशा में परिवर्तन',

      // AI Chat
      'ai_chat': 'एआई चैट',
      'educate_me': 'मुझे शिक्षित करें',
      'ask_question': 'एक सवाल पूछें...',
      'send': 'भेजें',
      'type_message': 'अपना संदेश टाइप करें...',

      // Nutrition
      'nutrition': 'पोषण',
      'water_intake': 'पानी का सेवन',
      'meals': 'भोजन',
      'add_meal': 'भोजन जोड़ें',

      // Breathing
      'breathing_exercise': 'श्वास व्यायाम',
      'start_exercise': 'व्यायाम शुरू करें',
      'inhale': 'सांस लें',
      'hold': 'रोकें',
      'exhale': 'सांस छोड़ें',

      // Appointments
      'appointment': 'नियुक्ति',
      'add_appointment': 'नियुक्ति जोड़ें',
      'appointment_date': 'नियुक्ति की तारीख',
      'appointment_time': 'नियुक्ति का समय',
      'doctor_name': 'डॉक्टर का नाम',
      'clinic_name': 'क्लिनिक का नाम',

      // Validation
      'please_enter': 'कृपया दर्ज करें',
      'please_select': 'कृपया चुनें',
      'invalid_email': 'अमान्य ईमेल',
      'required_field': 'यह फील्ड आवश्यक है',

      // Reset & Restart
      'reset_restart': 'रीसेट और पुनः शुरू करें',
      'clear_all_data':
          'सभी ऐप डेटा साफ़ करें और ताज़ा सेटअप के साथ पुनः शुरू करें। यह आपको लॉगआउट करेगा और सभी ट्रैकर्स को रीसेट करेगा।',
      'logout_confirm': 'क्या आप निश्चित हैं कि आप जारी रखना चाहते हैं?',
      'logging_out': 'लॉगआउट हो रहे हैं...',
      'data_cleared': 'सभी डेटा साफ़ किया गया। लॉगिन पर वापस जा रहे हैं...',

      // Educate Me
      'learn_about': 'मासिक धर्म, रजोनिवृत्ति और गर्भावस्था के बारे में जानें',

      // Report
      'report': 'रिपोर्ट',
      'print_report': 'रिपोर्ट प्रिंट करें',
      'export_pdf': 'पीडीएफ के रूप में निर्यात करें',
      'share_report': 'रिपोर्ट साझा करें',

      // Onboarding
      'welcome': 'स्वागत है',
      'get_started': 'शुरू करें',
      'select_tracker': 'अपना ट्रैकर चुनें',
      'setup_profile': 'अपनी प्रोफाइल सेट करें',
      'complete_setup': 'सेटअप पूरा करें',

      // Errors
      'network_error': 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।',
      'server_error': 'सर्वर त्रुटि। कृपया बाद में पुनः प्रयास करें।',
      'something_wrong': 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।',

      // Additional UI Strings
      'your_profile': 'आपकी प्रोफाइल',
      'changing_tracker_info':
          'ट्रैकर बदलने से आपकी होम स्क्रीन स्विच हो जाएगी। आपका डेटा सुरक्षित रहेगा।',
      'upload_medical_report_desc':
          'अपनी चिकित्सा रिपोर्ट की एक छवि अपलोड करें और हमारा एआई इसका विश्लेषण करेगा और एक आसान सारांश प्रदान करेगा।',
      'error_saving_profile':
          'प्रोफाइल सहेजने में त्रुटि। कृपया पुनः प्रयास करें।',
      'day': 'दिन',
      'luteal_phase': 'ल्यूटियल चरण',
      'menstrual_phase': 'मासिक धर्म चरण',
      'follicular_phase': 'फॉलिकुलर चरण',
      'ovulation_phase': 'ओवुलेशन चरण',
      'tomorrow': 'कल',
      'avg_cycle': 'औसत चक्र',
      'days': 'दिन',
      'pcos_tracking': 'पीसीओएस ट्रैकिंग',
      'specialized_tracking_pcos': 'पीसीओएस के लिए विशेष ट्रैकिंग',
      'log_today': 'आज लॉग करें',
      'flow_level': 'प्रवाह स्तर',
      'light': 'हल्का',
      'medium': 'मध्यम',
      'heavy': 'भारी',
      'spotting': 'स्पॉटिंग',
      'none': 'कोई नहीं',
      'how_are_you_feeling': 'आप कैसा महसूस कर रहे हैं?',
      'managing_wellness': 'अपनी कल्याण यात्रा का प्रबंधन',
      'days_tracked': 'ट्रैक किए गए दिन',
      'avg_symptoms': 'औसत लक्षण',
      'per_day': '/दिन',
      'understanding_menopause': 'रजोनिवृत्ति को समझना',
      'normal_symptoms': 'सामान्य लक्षण',
      'when_to_see_doctor': 'डॉक्टर को कब देखें',
      'good_morning': 'सुप्रभात! 💜',
      'your_profile_text': 'आपकी प्रोफाइल',
      'bmi_category': 'बीएमआई',
      'invalid_age': 'कृपया एक वैध आयु दर्ज करें',
      'invalid_height': 'अमान्य ऊंचाई',
      'invalid_weight': 'अमान्य वजन',
      'no_summary_available': 'कोई सारांश उपलब्ध नहीं',
    },
  };

  static String get(String key, String language) {
    return translations[language]?[key] ?? translations['en']?[key] ?? key;
  }
}
