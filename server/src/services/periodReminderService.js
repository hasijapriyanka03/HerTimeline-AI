const { GoogleGenAI } = require('@google/genai');
const db = require('./database');

class PeriodReminderService {
  constructor() {
    this.apiKey = process.env.AGORA_LLM_API_KEY || process.env.GEMINI_API_KEY;
    this.client = new GoogleGenAI({ apiKey: this.apiKey });
    this.model = this.client.models;
  }

  /**
   * Generate cute, loving period reminder based on user's previous logs
   * @param {string} userId - User ID
   * @param {number} daysUntil - Days until next period
   * @returns {Promise<Object>} {title, body}
   */
  async generatePeriodReminder(userId, daysUntil) {
    try {
      // Get user's recent logs
      const logs = await this.getMenstruationLogs(userId);

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
        .find({ user_id: userId, category: 'menstruation' })
        .value();

      // Build context for Gemini
      const context = this.buildContext(
        daysUntil,
        logs,
        profile,
        wallet,
        streak
      );

      // Generate reminder using Gemini
      const reminder = await this.generateWithGemini(context);

      return reminder;
    } catch (error) {
      console.error('Error generating period reminder:', error);
      return this.getDefaultReminder(daysUntil);
    }
  }

  /**
   * Build context for Gemini from user data
   */
  buildContext(daysUntil, logs, profile, wallet, streak) {
    const recentLogs = logs.slice(0, 10); // Last 10 logs
    const moods = recentLogs.map(l => l.mood).filter(Boolean);
    const symptoms = recentLogs.map(l => l.symptoms).filter(Boolean).flat();
    const flowLevels = recentLogs.map(l => l.flow_level).filter(Boolean);

    // Calculate average cycle length
    let avgCycleLength = 28;
    if (recentLogs.length > 1) {
      const dates = recentLogs
        .map(l => new Date(l.date || l.created_at))
        .sort((a, b) => b - a);
      
      if (dates.length > 1) {
        const daysDiff = (dates[0] - dates[dates.length - 1]) / (1000 * 60 * 60 * 24);
        avgCycleLength = Math.round(daysDiff / (dates.length - 1));
      }
    }

    // Get most common symptoms
    const symptomCounts = {};
    symptoms.forEach(s => {
      symptomCounts[s] = (symptomCounts[s] || 0) + 1;
    });
    const commonSymptoms = Object.entries(symptomCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([s]) => s);

    // Get most common moods
    const moodCounts = {};
    moods.forEach(m => {
      moodCounts[m] = (moodCounts[m] || 0) + 1;
    });
    const commonMoods = Object.entries(moodCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 2)
      .map(([m]) => m);

    return {
      daysUntil,
      userName: profile?.name || 'Beautiful',
      recentLogs: recentLogs.length,
      commonSymptoms,
      commonMoods,
      flowLevels: [...new Set(flowLevels)],
      walletPoints: wallet?.total_points || 0,
      streakDays: streak?.current_streak || 0,
      avgCycleLength,
      lastLogDate: recentLogs[0]?.date || recentLogs[0]?.created_at,
    };
  }

  /**
   * Generate reminder using Gemini AI
   */
  async generateWithGemini(context) {
    const prompt = this.buildPrompt(context);

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
        : this.getDefaultReminder(context.daysUntil).title;

      const body = bodyLine
        ? bodyLine.replace('Body:', '').trim()
        : this.getDefaultReminder(context.daysUntil).body;

      return { title, body };
    } catch (error) {
      console.error('Error calling Gemini:', error);
      return this.getDefaultReminder(context.daysUntil);
    }
  }

  /**
   * Build prompt for Gemini
   */
  buildPrompt(context) {
    const daysText = context.daysUntil === 0 
      ? 'today' 
      : context.daysUntil === 1 
      ? 'tomorrow' 
      : `in ${context.daysUntil} days`;

    return `You are a caring, loving health companion. Generate a cute, sweet period reminder for a user.

User Context:
- Name: ${context.userName}
- Period coming: ${daysText}
- Average cycle: ${context.avgCycleLength} days
- Streak: ${context.streakDays} days
- Wallet Points: ${context.walletPoints}
- Common symptoms: ${context.commonSymptoms.join(', ') || 'None logged'}
- Common moods: ${context.commonMoods.join(', ') || 'Not tracked'}
- Recent logs: ${context.recentLogs} entries
- Last log: ${context.lastLogDate || 'Never'}

Requirements:
1. Be CUTE, LOVING, and SUPPORTIVE
2. Acknowledge their upcoming period
3. Reference their specific symptoms if available
4. Include preparation tips if period is soon (0-2 days)
5. Be encouraging about their tracking streak
6. Use warm, caring language
7. Include relevant emojis (🌸, 💕, 🫂, 💜, etc.)
8. Keep it 2-3 sentences max
9. Make them feel cared for and supported
10. Avoid clinical language - be warm and personal

Format your response as:
Title: [emoji] [Cute title]
Body: [Warm, loving message]`;
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
   * Get default reminder if Gemini fails
   */
  getDefaultReminder(daysUntil) {
    if (daysUntil === 0) {
      return {
        title: '🌸 Your Period is Here',
        body: 'Your period is here today, beautiful! Take care of yourself - rest, hydrate, and be gentle. You deserve all the love and care. 💕',
      };
    } else if (daysUntil === 1) {
      return {
        title: '🌸 Period Coming Tomorrow',
        body: 'Your period is coming tomorrow! Get some rest, stock up on your favorites, and prepare to be extra kind to yourself. You\'ve got this! 💜',
      };
    } else if (daysUntil <= 3) {
      return {
        title: '🌸 Period Coming Soon',
        body: `Your period is coming in ${daysUntil} days! Start preparing - grab your comfort items and plan some self-care. You deserve to feel supported. 🫂`,
      };
    } else if (daysUntil <= 7) {
      return {
        title: '🌼 Period Reminder',
        body: `Your period is coming in ${daysUntil} days. Keep tracking and taking care of yourself - you're doing amazing! 💕`,
      };
    } else {
      return {
        title: '💜 Period Reminder',
        body: `Your period is expected in ${daysUntil} days. Keep up with your amazing tracking streak! 🌸`,
      };
    }
  }
}

module.exports = new PeriodReminderService();
