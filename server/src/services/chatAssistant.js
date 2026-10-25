const fs = require('fs');
const path = require('path');
const ChatMemory = require('../models/chatMemory.model');

class ChatAssistant {
  constructor() {
    this.faqData = this.loadFAQ();
  }

  loadFAQ() {
    try {
      const dataPath = path.join(__dirname, '../data/pregnancy_faq.json');
      return JSON.parse(fs.readFileSync(dataPath, 'utf8'));
    } catch (error) {
      console.error('Error loading FAQ:', error);
      return [];
    }
  }

  async chat(userId, message, context = {}) {
    // Store user message
    ChatMemory.addMessage(userId, 'user', message);

    const messageLower = message.toLowerCase();

    // Detect mood/emotional content
    if (this.containsMoodKeywords(messageLower)) {
      const response = this.handleMoodMessage(messageLower, context);
      ChatMemory.addMessage(userId, 'ai', response);
      return response;
    }

    // Check FAQ
    const faqMatch = this.findFAQMatch(messageLower);
    if (faqMatch) {
      const response = `${faqMatch.answer}\n\n${this.getDisclaimer()}`;
      ChatMemory.addMessage(userId, 'ai', response);
      return response;
    }

    // General supportive response
    const response = this.getGeneralResponse(messageLower, context);
    ChatMemory.addMessage(userId, 'ai', response);
    return response;
  }

  containsMoodKeywords(message) {
    const moodKeywords = [
      'stressed', 'anxious', 'worried', 'scared', 'nervous',
      'tired', 'exhausted', 'overwhelmed', 'sad', 'depressed',
      'happy', 'excited', 'grateful', 'calm', 'peaceful'
    ];
    return moodKeywords.some(keyword => message.includes(keyword));
  }

  handleMoodMessage(message, context) {
    if (message.includes('stressed') || message.includes('anxious') || message.includes('overwhelmed')) {
      return `I'm here for you, Mensa. 💕 Feeling stressed during pregnancy is completely normal. Here are some things that might help:\n\n` +
        `• Try our breathing exercise - it can help calm your mind\n` +
        `• Take a short walk in fresh air\n` +
        `• Talk to someone you trust\n` +
        `• Rest when you can\n\n` +
        `Remember, you're doing an amazing job. If anxiety persists, please talk to your healthcare provider about it.`;
    }

    if (message.includes('tired') || message.includes('exhausted')) {
      return `Fatigue is one of the most common pregnancy symptoms, especially in the first and third trimesters. Your body is working hard! 💪\n\n` +
        `Tips to manage:\n` +
        `• Take short naps when possible\n` +
        `• Stay hydrated\n` +
        `• Eat iron-rich foods\n` +
        `• Don't push yourself too hard\n\n` +
        `Listen to your body and rest when you need to.`;
    }

    if (message.includes('happy') || message.includes('excited') || message.includes('grateful')) {
      return `That's wonderful to hear! 🌟 Your positive energy is great for both you and your baby. Keep embracing these beautiful moments of your pregnancy journey!`;
    }

    if (message.includes('sad') || message.includes('depressed')) {
      return `I'm sorry you're feeling this way. 💙 Mood changes are common during pregnancy due to hormones, but persistent sadness should be addressed.\n\n` +
        `Please reach out to:\n` +
        `• Your healthcare provider\n` +
        `• A mental health professional\n` +
        `• A trusted friend or family member\n\n` +
        `Perinatal depression is real and treatable. You don't have to go through this alone.`;
    }

    return `Thank you for sharing how you're feeling. Your emotional wellbeing is just as important as your physical health. I'm here to support you. 💕`;
  }

  findFAQMatch(message) {
    return this.faqData.find(faq =>
      message.includes(faq.question.toLowerCase()) ||
      faq.question.toLowerCase().split(' ').some(word =>
        word.length > 4 && message.includes(word)
      )
    );
  }

  getGeneralResponse(message, context) {
    const week = context.week || 0;

    if (message.includes('week') || message.includes('baby')) {
      return `You're in week ${week} of your pregnancy journey! Your baby is growing and developing every day. Check the Weekly Progress section for detailed information about this week. 🌸\n\n${this.getDisclaimer()}`;
    }

    if (message.includes('help') || message.includes('support')) {
      return `I'm here to help you, Mensa! 💕 I can:\n\n` +
        `• Answer pregnancy-related questions\n` +
        `• Provide emotional support\n` +
        `• Suggest wellness activities\n` +
        `• Guide you through breathing exercises\n\n` +
        `What would you like to know about?`;
    }

    return `I'm here to support you through your pregnancy journey! Feel free to ask me about:\n\n` +
      `• Pregnancy symptoms and what's normal\n` +
      `• Nutrition and foods to eat/avoid\n` +
      `• Exercise and wellness tips\n` +
      `• Emotional support and stress management\n\n` +
      `${this.getDisclaimer()}`;
  }

  getDisclaimer() {
    return '⚕️ Remember: This guidance doesn\'t replace medical advice. Always consult your healthcare provider for medical concerns.';
  }
}

module.exports = new ChatAssistant();
