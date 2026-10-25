const db = require('./database');

class PersonalizedMessageService {
  /**
   * Generate a sweet streak reminder message based on user logs
   * @param {string} userId - User ID
   * @param {string} tracker - Tracker type (menstruation, pregnancy, menopause)
   * @param {number} streakDays - Current streak days
   * @param {string} userName - User's name
   * @returns {string} Personalized message
   */
  generateStreakMessage(userId, tracker, streakDays, userName) {
    const messages = {
      menstruation: {
        1: `Hey ${userName}! 🌸 You just started your streak! Keep going, you've got this! Log today to earn 10 points.`,
        3: `${userName}! 🔥 You're on a 3-day streak! You're doing amazing! Keep it up and earn more points.`,
        7: `Wow ${userName}! 🎉 A whole week of logging! You're incredible! Keep this momentum going.`,
        14: `${userName}! 🌟 Two weeks of consistency! You're a superstar! Keep shining and earning rewards.`,
        30: `${userName}! 👑 30 days of dedication! You're absolutely crushing it! Keep being awesome!`,
      },
      pregnancy: {
        1: `Hi ${userName}! 🤰 Welcome to your pregnancy journey! You just started logging. Keep tracking for amazing insights!`,
        3: `${userName}! 💕 3 days of tracking your pregnancy! You're doing great! Keep it up for 10 points.`,
        7: `${userName}! 🌈 A week of pregnancy tracking! You're so dedicated! Keep going, mama!`,
        14: `${userName}! 💪 Two weeks of consistent tracking! You're amazing! Keep caring for yourself and baby.`,
        30: `${userName}! 👶 30 days of beautiful tracking! You're an inspiration! Keep this wonderful journey going!`,
      },
      menopause: {
        1: `${userName}! 🌺 You started tracking your menopause journey! Great first step! Keep logging for insights.`,
        3: `${userName}! 💫 3 days of tracking! You're taking great care of yourself! Keep it up.`,
        7: `${userName}! ✨ A week of consistency! You're doing wonderfully! Keep tracking and earning rewards.`,
        14: `${userName}! 🌸 Two weeks of dedication! You're handling this beautifully! Keep going strong.`,
        30: `${userName}! 💎 30 days of amazing tracking! You're so strong! Keep being fabulous!`,
      },
    };

    const trackerMessages = messages[tracker] || messages.menstruation;
    
    // Find the appropriate message based on streak days
    let message = trackerMessages[streakDays];
    if (!message) {
      // Find the closest milestone
      const milestones = Object.keys(trackerMessages).map(Number).sort((a, b) => b - a);
      for (const milestone of milestones) {
        if (streakDays >= milestone) {
          message = trackerMessages[milestone];
          break;
        }
      }
    }

    return message || `${userName}! 🎯 You're on a ${streakDays}-day streak! Keep it up and earn 10 points!`;
  }

  /**
   * Generate a sweet period reminder message based on user history
   * @param {string} userId - User ID
   * @param {number} daysUntil - Days until next period
   * @param {string} userName - User's name
   * @returns {string} Personalized message
   */
  generatePeriodReminderMessage(userId, daysUntil, userName) {
    const logs = db.get('menstruationLogs')
      .filter({ user_id: userId })
      .sortBy('date')
      .reverse()
      .take(5)
      .value();

    let message = '';

    if (daysUntil === 0) {
      const sweetMessages = [
        `${userName}! 🌸 Your period is here! Take it easy today, you deserve some self-care. 💕`,
        `${userName}! 🌺 Period day! Remember to be gentle with yourself. You've got this! 💪`,
        `${userName}! 🌷 Your cycle continues! Listen to your body and rest when you need to. 💗`,
      ];
      message = sweetMessages[Math.floor(Math.random() * sweetMessages.length)];
    } else if (daysUntil === 1) {
      const sweetMessages = [
        `${userName}! 🌸 Your period is coming tomorrow! Get some rest and stay hydrated. 💧`,
        `${userName}! 🌺 Tomorrow's the day! Prepare yourself with comfort and care. 💕`,
        `${userName}! 🌷 One more day! Make sure you have everything you need ready. 💪`,
      ];
      message = sweetMessages[Math.floor(Math.random() * sweetMessages.length)];
    } else if (daysUntil <= 3) {
      const sweetMessages = [
        `${userName}! 🌸 Your period is coming in ${daysUntil} days! Start preparing and taking extra care of yourself. 💕`,
        `${userName}! 🌺 ${daysUntil} days until your period! Make sure you're staying hydrated and rested. 💧`,
        `${userName}! 🌷 ${daysUntil} days to go! This is a great time to plan some self-care activities. 💆‍♀️`,
      ];
      message = sweetMessages[Math.floor(Math.random() * sweetMessages.length)];
    } else {
      const sweetMessages = [
        `${userName}! 🌸 Your period is expected in ${daysUntil} days. Keep tracking for better insights! 📊`,
        `${userName}! 🌺 ${daysUntil} days until your next period. You're doing great tracking your cycle! 💪`,
        `${userName}! 🌷 ${daysUntil} days to go! Keep up with your logging for accurate predictions. 📝`,
      ];
      message = sweetMessages[Math.floor(Math.random() * sweetMessages.length)];
    }

    return message;
  }

  /**
   * Generate a sweet health tip based on user's recent logs
   * @param {string} userId - User ID
   * @param {string} tracker - Tracker type
   * @param {string} userName - User's name
   * @returns {string} Personalized health tip
   */
  generateHealthTip(userId, tracker, userName) {
    const logs = db.get(`${tracker}Logs`)
      .filter({ user_id: userId })
      .sortBy('date')
      .reverse()
      .take(10)
      .value();

    let tip = '';

    if (tracker === 'menstruation') {
      // Analyze symptoms and moods
      const symptoms = {};
      const moods = {};

      logs.forEach(log => {
        if (log.symptoms) {
          log.symptoms.forEach(symptom => {
            symptoms[symptom] = (symptoms[symptom] || 0) + 1;
          });
        }
        if (log.mood) {
          moods[log.mood] = (moods[log.mood] || 0) + 1;
        }
      });

      const topSymptom = Object.keys(symptoms).sort((a, b) => symptoms[b] - symptoms[a])[0];
      const topMood = Object.keys(moods).sort((a, b) => moods[b] - moods[a])[0];

      if (topSymptom === 'Cramps') {
        tip = `${userName}! 💕 We noticed you often have cramps. Try gentle yoga, heating pads, or magnesium supplements. You deserve comfort! 🧘‍♀️`;
      } else if (topSymptom === 'Bloating') {
        tip = `${userName}! 💧 Bloating bothering you? Stay hydrated, reduce salt intake, and try light exercise. You'll feel better soon! 💪`;
      } else if (topSymptom === 'Fatigue') {
        tip = `${userName}! 😴 Feeling tired? Make sure you're getting enough iron-rich foods and rest. Your body needs extra care! 💗`;
      } else if (topMood === 'Anxious') {
        tip = `${userName}! 🧘‍♀️ We noticed you feel anxious sometimes. Try meditation, deep breathing, or journaling. You've got this! 💕`;
      } else if (topMood === 'Irritable') {
        tip = `${userName}! 💪 Feeling irritable? That's normal! Try exercise, spend time in nature, or talk to someone. You're doing great! 🌿`;
      } else {
        tip = `${userName}! 🌸 You're doing amazing tracking your cycle! Keep it up for better insights into your health! 📊`;
      }
    } else if (tracker === 'pregnancy') {
      tip = `${userName}! 🤰 You're doing an amazing job tracking your pregnancy! Remember to stay hydrated, rest well, and listen to your body. You're growing a miracle! 💕`;
    } else if (tracker === 'menopause') {
      tip = `${userName}! 🌺 You're handling this transition beautifully! Stay active, eat well, and be kind to yourself. You're stronger than you know! 💪`;
    }

    return tip;
  }

  /**
   * Generate a sweet motivation message
   * @param {string} userName - User's name
   * @param {number} totalPoints - User's total points
   * @returns {string} Motivational message
   */
  generateMotivationMessage(userName, totalPoints) {
    const messages = [
      `${userName}! 🌟 You've earned ${totalPoints} points! You're crushing your health goals! Keep going! 💪`,
      `${userName}! 💎 Amazing! You have ${totalPoints} points! You're an inspiration to us all! 🎉`,
      `${userName}! 👑 Wow! ${totalPoints} points! You're absolutely incredible! Keep being awesome! ✨`,
      `${userName}! 🔥 ${totalPoints} points! You're on fire! Your dedication is inspiring! 🚀`,
      `${userName}! 💕 You've got ${totalPoints} points! You're taking such good care of yourself! 🌸`,
    ];

    return messages[Math.floor(Math.random() * messages.length)];
  }

  /**
   * Generate a sweet appointment reminder
   * @param {string} userName - User's name
   * @param {string} appointmentTitle - Appointment title
   * @param {string} appointmentTime - Appointment time
   * @param {number} minutesBefore - Minutes before appointment
   * @returns {string} Personalized reminder
   */
  generateAppointmentReminder(userName, appointmentTitle, appointmentTime, minutesBefore) {
    if (minutesBefore <= 15) {
      return `${userName}! 📅 Your ${appointmentTitle} is starting soon at ${appointmentTime}! Get ready! 💪`;
    } else if (minutesBefore <= 60) {
      return `${userName}! 📅 Your ${appointmentTitle} is in ${minutesBefore} minutes at ${appointmentTime}. See you soon! 💕`;
    } else {
      return `${userName}! 📅 Reminder: Your ${appointmentTitle} is at ${appointmentTime}. Don't forget! 🌸`;
    }
  }

  /**
   * Generate a sweet voucher notification
   * @param {string} userName - User's name
   * @param {string} voucherName - Voucher name
   * @param {number} points - Points required
   * @returns {string} Personalized voucher message
   */
  generateVoucherMessage(userName, voucherName, points) {
    const messages = [
      `${userName}! 🎁 Exciting! You can now redeem "${voucherName}" for ${points} points! Treat yourself! 💕`,
      `${userName}! 🎉 Great news! "${voucherName}" is now available for ${points} points! You deserve it! ✨`,
      `${userName}! 🌟 Amazing! You've unlocked "${voucherName}" for ${points} points! Go get it! 🎊`,
      `${userName}! 💎 Wonderful! "${voucherName}" is ready for you at ${points} points! Enjoy! 💪`,
    ];

    return messages[Math.floor(Math.random() * messages.length)];
  }

  /**
   * Generate a sweet daily check-in reminder
   * @param {string} userName - User's name
   * @param {string} tracker - Tracker type
   * @returns {string} Daily reminder message
   */
  generateDailyCheckInReminder(userName, tracker) {
    const messages = {
      menstruation: [
        `${userName}! 🌸 Don't forget to log your cycle today! It only takes a minute and helps us give you better insights! 📊`,
        `${userName}! 🌺 How are you feeling today? Log your mood and symptoms to track your cycle! 💕`,
        `${userName}! 🌷 Time to check in! Log your daily update and keep your streak going! 🔥`,
      ],
      pregnancy: [
        `${userName}! 🤰 How's your pregnancy journey today? Log your updates and keep tracking! 💕`,
        `${userName}! 👶 Don't forget to log today! Your baby is growing and we want to track your wellness! 🌈`,
        `${userName}! 💪 Time for your daily pregnancy check-in! Keep up the amazing work! 🎉`,
      ],
      menopause: [
        `${userName}! 🌺 How are you doing today? Log your symptoms and keep tracking your journey! 💕`,
        `${userName}! ✨ Time to check in! Your daily log helps us understand your experience better! 📊`,
        `${userName}! 💪 Don't forget to log today! You're doing an amazing job! 🌸`,
      ],
    };

    const trackerMessages = messages[tracker] || messages.menstruation;
    return trackerMessages[Math.floor(Math.random() * trackerMessages.length)];
  }
}

module.exports = new PersonalizedMessageService();
