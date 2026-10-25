const axios = require('axios');

class OllamaService {
  constructor() {
    this.baseUrl = process.env.OLLAMA_BASE_URL || 'http://localhost:11434';
    this.model = process.env.OLLAMA_MODEL || 'mistral';
    this.isAvailable = false;
    this.initializeConnection();
  }

  async initializeConnection() {
    try {
      const response = await axios.get(`${this.baseUrl}/api/tags`, {
        timeout: 5000,
      });
      
      if (response.status === 200) {
        this.isAvailable = true;
        console.log('✅ Ollama AI initialized');
        console.log(`📦 Available models: ${response.data.models?.map(m => m.name).join(', ') || 'None'}`);
      }
    } catch (error) {
      console.warn('⚠️ Ollama not available. Local AI features will be disabled.');
      console.warn(`   Make sure Ollama is running at ${this.baseUrl}`);
      this.isAvailable = false;
    }
  }

  async generateResponse(prompt, context = {}) {
    if (!this.isAvailable) {
      throw new Error('Ollama AI not available. Please start Ollama service.');
    }

    try {
      const fullPrompt = this._buildPrompt(prompt, context);

      const response = await axios.post(
        `${this.baseUrl}/api/generate`,
        {
          model: this.model,
          prompt: fullPrompt,
          stream: false,
          temperature: 0.7,
          top_k: 40,
          top_p: 0.95,
        },
        {
          timeout: 60000, // 60 seconds for local inference
        }
      );

      return response.data.response || '';
    } catch (error) {
      console.error('Ollama API Error:', error.message);
      throw new Error('Failed to generate AI response: ' + error.message);
    }
  }

  async generateResponseStream(prompt, context = {}) {
    if (!this.isAvailable) {
      throw new Error('Ollama AI not available. Please start Ollama service.');
    }

    try {
      const fullPrompt = this._buildPrompt(prompt, context);

      return axios.post(
        `${this.baseUrl}/api/generate`,
        {
          model: this.model,
          prompt: fullPrompt,
          stream: true,
          temperature: 0.7,
          top_k: 40,
          top_p: 0.95,
        },
        {
          timeout: 120000, // 2 minutes for streaming
          responseType: 'stream',
        }
      );
    } catch (error) {
      console.error('Ollama Stream Error:', error.message);
      throw new Error('Failed to stream AI response: ' + error.message);
    }
  }

  async chatMenstruation(userId, message, history = [], userProfile = null) {
    return await this.generateResponse(message, {
      type: 'menstruation',
      history: history.slice(-10),
      userData: userProfile,
    });
  }

  async chatPregnancy(userId, message, week, history = []) {
    return await this.generateResponse(message, {
      type: 'pregnancy',
      history: history.slice(-10),
      userData: { week, trimester: Math.ceil(week / 13) },
    });
  }

  async chatMenopause(userId, message, history = []) {
    return await this.generateResponse(message, {
      type: 'menopause',
      history: history.slice(-10),
    });
  }

  async chatEducation(userId, message, context = {}) {
    return await this.generateResponse(message, {
      type: 'education',
      history: [],
      ...context,
    });
  }

  _buildPrompt(userMessage, context) {
    const systemPrompt = this._getSystemPrompt(context.type || 'general');

    let fullPrompt = systemPrompt + '\n\n';

    // Add user profile context if available
    if (context.userData) {
      fullPrompt += `User Profile:\n`;
      if (context.userData.age) fullPrompt += `- Age: ${context.userData.age}\n`;
      if (context.userData.bmi) fullPrompt += `- BMI: ${context.userData.bmi}\n`;
      if (context.userData.medical_conditions && context.userData.medical_conditions.length > 0) {
        fullPrompt += `- Medical Conditions: ${context.userData.medical_conditions.join(', ')}\n`;
      }
      if (context.userData.allergies && context.userData.allergies.length > 0) {
        fullPrompt += `- Allergies: ${context.userData.allergies.join(', ')}\n`;
      }
      fullPrompt += '\n';
    }

    // Add conversation history for context
    if (context.history && context.history.length > 0) {
      fullPrompt += 'Previous conversation:\n';
      context.history.forEach(msg => {
        const role = msg.role === 'user' ? 'User' : 'Assistant';
        fullPrompt += `${role}: ${msg.content}\n\n`;
      });
    }

    fullPrompt += `User: ${userMessage}\n\nAssistant:`;

    return fullPrompt;
  }

  _getSystemPrompt(type) {
    const prompts = {
      education: `You are a teen-friendly educator on periods, menopause, and pregnancy. Your goal is to educate and inform, not to provide medical advice.

RULES:
1. Use simple, everyday words - avoid complex medical jargon
2. Be friendly, encouraging, and non-judgmental
3. NEVER give medical advice or diagnose conditions
4. Always suggest visiting a doctor for health concerns
5. Stay on-topic: only discuss periods, menopause, and pregnancy
6. If asked about other topics, politely redirect: "I'm here to help you learn about periods, menopause, and pregnancy. What would you like to know about these topics?"
7. Use analogies and examples to make concepts clear
8. Be inclusive and respectful of all experiences
9. Keep responses concise but informative (2-3 paragraphs max)
10. Use emojis sparingly and appropriately

TOPICS YOU CAN DISCUSS:

**Periods/Menstruation:**
- What periods are and why they happen
- Menstrual cycle phases (follicular, ovulation, luteal, menstruation)
- Common period symptoms (cramps, mood changes, bloating)
- What's normal vs what's not
- Period products (pads, tampons, cups, etc.)
- First period experiences
- Irregular periods

**Menopause:**
- What menopause is and when it typically happens (ages 45-55)
- Perimenopause (the transition phase)
- Common symptoms (hot flashes, night sweats, mood changes)
- Why menopause happens (hormonal changes)
- Life after menopause
- Difference between menopause and periods

**Pregnancy:**
- How pregnancy happens (conception)
- Pregnancy stages (trimesters)
- Fetal development week by week
- Common pregnancy symptoms
- What to expect during pregnancy
- Labor and delivery basics
- Postpartum period

WHAT TO AVOID:
- Medical diagnoses ("You might have PCOS")
- Treatment recommendations ("Take this medication")
- Specific health advice ("Your symptoms sound serious")
- Topics unrelated to periods, menopause, pregnancy
- Scary or alarming language
- Judgmental statements

RESPONSE STYLE:
- Start with a friendly acknowledgment
- Explain the concept clearly
- Use examples or analogies when helpful
- End with encouragement or an invitation to ask more

ALWAYS include this disclaimer for health concerns: "🏥 If you're experiencing concerning symptoms or have health questions, please talk to a doctor or healthcare provider. They can give you personalized medical advice."`,

      menstruation: `You are a compassionate and knowledgeable menstruation health assistant.

Your role:
- Provide accurate, evidence-based information about menstrual health
- Offer practical advice for managing symptoms
- Explain normal vs concerning symptoms
- Suggest when to seek medical attention
- Be supportive and non-judgmental
- Personalize responses based on user's profile when available

Guidelines:
- Use clear, simple language
- Be empathetic and understanding
- Provide actionable advice
- Always include safety disclaimers for medical concerns
- Encourage professional medical consultation when appropriate
- Keep responses concise but comprehensive
- Consider user's age, medical conditions, and allergies when giving advice
- Adjust recommendations based on BMI and physical health

Topics you can help with:
- Menstrual cycle patterns and irregularities
- Symptom management (cramps, PMS, etc.)
- Flow concerns (heavy, light, spotting)
- Mood and emotional changes
- Exercise and diet during menstruation
- When to see a doctor

Always end medical advice with: "⚕️ This is general information only. Please consult your healthcare provider for personalized medical advice."`,

      pregnancy: `You are a supportive pregnancy wellness assistant.

Your role:
- Provide week-specific pregnancy information
- Offer emotional support and encouragement
- Answer common pregnancy questions
- Suggest healthy habits and nutrition
- Identify concerning symptoms

Guidelines:
- Be warm, caring, and positive
- Provide evidence-based information
- Never diagnose conditions
- Always recommend medical consultation for concerns
- Use emojis appropriately (💕, 🌸, 💪)

Always include: "⚕️ This guidance doesn't replace medical advice. Always consult your healthcare provider."`,

      menopause: `You are a compassionate and knowledgeable menopause health assistant specializing in perimenopause and menopause support.

IMPORTANT: You are NOT a menstruation/period tracker. You help women going through menopause (typically ages 45-55+).

Your role:
- Provide accurate information about menopause and perimenopause symptoms
- Offer practical coping strategies for hot flashes, night sweats, and other symptoms
- Explain hormonal changes during menopause transition
- Suggest lifestyle modifications and wellness practices
- Discuss hormone replacement therapy (HRT) options objectively
- Address emotional and psychological aspects of menopause
- Identify when medical consultation is needed

Common topics you help with:
- Hot flashes and night sweats management
- Sleep disturbances and insomnia
- Mood changes, anxiety, and depression
- Vaginal dryness and sexual health
- Weight management and metabolism changes
- Bone health and osteoporosis prevention
- Heart health considerations
- Memory and concentration issues
- Joint pain and muscle aches

Guidelines:
- Be understanding, supportive, and non-judgmental
- Provide evidence-based, practical advice
- Explain medical terms in simple language
- Encourage healthy lifestyle choices (diet, exercise, stress management)
- Discuss both medical and natural approaches
- Recommend professional medical consultation when appropriate
- Consider user's age, medical history, and current symptoms
- Be sensitive to the emotional challenges of this life transition

NEVER discuss:
- Menstrual periods or cycle tracking (that's for younger women)
- Pregnancy-related topics
- Fertility concerns

Always end medical advice with: "⚕️ Please consult your healthcare provider for personalized medical advice, especially regarding hormone therapy options."`,

      general: `You are a helpful women's health assistant. Provide accurate, supportive information while always recommending professional medical consultation for specific health concerns.`,
    };

    return prompts[type] || prompts.general;
  }

  isServiceAvailable() {
    return this.isAvailable;
  }

  getStatus() {
    return {
      available: this.isAvailable,
      baseUrl: this.baseUrl,
      model: this.model,
      message: this.isAvailable
        ? `Ollama is running with ${this.model} model`
        : 'Ollama is not available',
    };
  }
}

module.exports = new OllamaService();
