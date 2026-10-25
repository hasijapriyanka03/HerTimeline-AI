const { GoogleGenAI } = require('@google/genai');
const db = require('./database');

class GeminiNotificationService {
  constructor() {
    this.apiKey = process.env.AGORA_LLM_API_KEY || process.env.GEMINI_API_KEY;
    this.client = new GoogleGenAI({ apiKey: this.apiKey });
    this.model = this.client.models;
  }

  /**
   * Generate personalized notification based on user logs
   * @param {string} userId - User ID
   * @param {string} tracker - Tracker type (menstruation, pregnancy, menopause)
   * @param {number} cycleDay - Current cycle day
   * @returns {Promise<Object>} {title, body}
   */
  async generatePersonalizedNotification(userId, tracker, cycleDay) {
    try {
      // Get user's recent logs
      let logs = [];
      if (tracker === 'menstruation') {
        logs = await this.getMenstruationLogs(userId);
      } else if (tracker === 'pregnancy') {
        logs = await this.getPregnancyLogs(userId);
      } else if (tracker === 'menopause') {
        logs = await this.getMenopauseLogs(userId);
      }

      // Get user profile
      const profile = db.get('userProfiles')
        .find({ user_id: userId })
        .value();

      // Get wallet info
      const wallet = db.get('userWallets')
        .find({ user_id: userId })
        .value();

      // Get streak info
      const streak = db.get('streaks')
        .find({ user_id: userId, category: tracker })
        .value();

      // Build context for Gemini
      const context = this.buildContext(
        tracker,
        cycleDay,
        logs,
        profile,
        wallet,
        streak
      );

      // Generate notification using Gemini
      const notification = await this.generateWithGemini(context, tracker);

      return notification;
    } catch (error) {
      console.error('Error generating personalized notification:', error);
      return this.getDefaultNotification(tracker, cycleDay);
    }
  }

  /**
   * Build context for Gemini from user data
   */
  buildContext(tracker, cycleDay, logs, profile, wallet, streak) {
    const recentLogs = logs.slice(0, 5); // Last 5 logs
    const moods = recentLogs.map(l => l.mood).filter(Boolean);
    const symptoms = recentLogs.map(l => l.symptoms).filter(Boolean).flat();
    const flowLevels = recentLogs.map(l => l.flow_level).filter(Boolean);

    return {
      tracker,
      cycleDay,
      recentLogs: recentLogs.length,
      moods: [...new Set(moods)],
      symptoms: [...new Set(symptoms)],
      flowLevels: [...new Set(flowLevels)],
      userName: profile?.name || 'User',
      walletPoints: wallet?.total_points || 0,
      streakDays: streak?.current_streak || 0,
      lastLogDate: recentLogs[0]?.date || recentLogs[0]?.created_at,
    };
  }

  /**
   * Generate notification using Gemini AI
   */
  async generateWithGemini(context, tracker) {
    const prompt = this.buildPrompt(context, tracker);

    try {
      const response = await this.model.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
        config: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        },
      });

      const text = response.text;

      // Parse the response
      const lines = text.split('\n').filter(l => l.trim());
      const titleLine = lines.find(l => l.startsWith('Title:'));
      const bodyLine = lines.find(l => l.startsWith('Body:'));

      const title = titleLine
        ? titleLine.replace('Title:', '').trim()
        : this.getDefaultTitle(tracker);

      const body = bodyLine
        ? bodyLine.replace('Body:', '').trim()
        : this.getDefaultBody(tracker);

      return { title, body };
    } catch (error) {
      console.error('Error calling Gemini:', error);
      return this.getDefaultNotification(tracker, context.cycleDay);
    }
  }

  /**
   * Build prompt for Gemini
   */
  buildPrompt(context, tracker) {
    const trackerInfo = {
      menstruation: 'menstrual cycle',
      pregnancy: 'pregnancy',
      menopause: 'menopause',
    };

    const trackerName = trackerInfo[tracker] || 'health';

    return `You are a supportive health companion AI. Generate a personalized, encouraging notification for a user tracking their ${trackerName}.

User Context:
- Name: ${context.userName}
- Current Day: ${context.cycleDay}
- Streak: ${context.streakDays} days
- Wallet Points: ${context.walletPoints}
- Recent Moods: ${context.moods.join(', ') || 'Not logged'}
- Recent Symptoms: ${context.symptoms.join(', ') || 'None'}
- Recent Flow Levels: ${context.flowLevels.join(', ') || 'Not applicable'}
- Last Log: ${context.lastLogDate || 'Never'}

Requirements:
1. Generate a UNIQUE, NON-REPETITIVE notification
2. Reference specific moods or symptoms from their logs if available
3. Be encouraging and supportive
4. Include an emoji
5. Keep it concise (1-2 sentences)
6. Avoid generic messages
7. Personalize based on their streak and points

Format your response as:
Title: [emoji] [Short title]
Body: [Personalized message]`;
  }

  /**
   * Get menstruation logs
   */
  async getMenstruationLogs(userId) {
    return db.get('menstruationLogs')
      .filter(l => l.user_id === userId)
      .value() || [];
  }

  /**
   * Get pregnancy logs
   */
  async getPregnancyLogs(userId) {
    return db.get('pregnancyLogs')
      .filter(l => l.user_id === userId)
      .value() || [];
  }

  /**
   * Get menopause logs
   */
  async getMenopauseLogs(userId) {
    return db.get('menopauseLogs')
      .filter(l => l.user_id === userId)
      .value() || [];
  }

  /**
   * Get default notification if Gemini fails
   */
  getDefaultNotification(tracker, cycleDay) {
    const defaults = {
      menstruation: {
        1: { title: '🌸 Menstrual Phase', body: 'Take care of yourself today. Rest, hydrate, and be kind to your body.' },
        6: { title: '🌼 Follicular Phase', body: 'Energy is rising! Great time for new activities and exercise.' },
        14: { title: '🔥 Ovulation Phase', body: 'Peak energy and confidence! Make the most of this phase.' },
        17: { title: '🌙 Luteal Phase', body: 'Time for self-care and reflection. Listen to your body.' },
      },
      pregnancy: {
        title: '👶 Pregnancy Update',
        body: 'Keep tracking your pregnancy journey. Your health matters!',
      },
      menopause: {
        title: '🌺 Menopause Support',
        body: 'You\'re doing great! Keep logging to track your wellness.',
      },
    };

    if (tracker === 'menstruation') {
      if (cycleDay <= 5) return defaults.menstruation[1];
      if (cycleDay <= 13) return defaults.menstruation[6];
      if (cycleDay <= 16) return defaults.menstruation[14];
      return defaults.menstruation[17];
    }

    return defaults[tracker] || { title: '💜 Health Reminder', body: 'Keep tracking your health!' };
  }

  /**
   * Get default title
   */
  getDefaultTitle(tracker) {
    const titles = {
      menstruation: '🌸 Health Reminder',
      pregnancy: '👶 Pregnancy Update',
      menopause: '🌺 Wellness Check',
    };
    return titles[tracker] || '💜 Health Reminder';
  }

  /**
   * Get default body
   */
  getDefaultBody(tracker) {
    const bodies = {
      menstruation: 'Keep tracking your cycle for better health insights.',
      pregnancy: 'Your pregnancy journey is important. Keep logging!',
      menopause: 'You\'re doing great! Keep tracking your wellness.',
    };
    return bodies[tracker] || 'Keep tracking your health!';
  }
}

module.exports = new GeminiNotificationService();
