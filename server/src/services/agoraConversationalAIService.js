const axios = require('axios');

class AgoraConversationalAIService {
  constructor() {
    this.appId = process.env.AGORA_APP_ID;
    this.customerId = process.env.AGORA_CUSTOMER_ID;
    this.customerSecret = process.env.AGORA_CUSTOMER_SECRET;
    this.baseUrl = 'https://api.agora.io/api/conversational-ai-agent/v2';

    this.llmApiKey = process.env.AGORA_LLM_API_KEY;
    this.llmModel = process.env.AGORA_LLM_MODEL || 'gemini-2.5-flash';

    this.ttsApiKey = process.env.AGORA_TTS_API_KEY;
    this.ttsModelId = process.env.AGORA_TTS_MODEL_ID || 'sonic-2';
    this.ttsVoiceId = process.env.AGORA_TTS_VOICE_ID || 'e07c00bc-4134-4eae-9ea4-1a55fb45746b';

    if (!this.appId || !this.customerId || !this.customerSecret) {
      console.warn(
        '⚠️ Agora Conversational AI credentials not fully configured. Some features will be disabled.',
      );
    }
  }

  /**
   * Generate base64 encoded credentials for Agora API authentication
   */
  _getAuthHeader() {
    const credentials = `${this.customerId}:${this.customerSecret}`;
    const base64Credentials = Buffer.from(credentials).toString('base64');
    return `Basic ${base64Credentials}`;
  }

  /**
   * Start a conversational AI agent
   * @param {string} channelName - Agora channel name
   * @param {string} token - Agora RTC token for the agent
   * @param {string} agentName - Unique name for the agent
   * @param {Array<number>} remoteUids - UIDs of remote users to interact with
   * @param {Object} systemMessages - Custom system messages for the LLM
   * @returns {Promise<Object>} Agent creation response with agent_id
   */
  async startAgent(
    channelName,
    token,
    agentName,
    remoteUids = [1002],
    systemMessages = null,
    mode = 'education',
  ) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🤖 Starting Agora Conversational AI agent: ${agentName}`);
      console.log(`📋 LLM: ${this.llmModel}`);
      console.log(`🔊 TTS: Cartesia ${this.ttsModelId}`);
      console.log(`🎤 ASR: Ares`);
      console.log(`🎯 Mode: ${mode}`);

      // Build Gemini URL with API key in query param (per Agora docs)
      // Note: Using gemini-1.5-flash as fallback if 2.5-flash has quota issues
      const modelToUse = this.llmModel || 'gemini-2.5-flash';
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${modelToUse}:streamGenerateContent?alt=sse&key=${this.llmApiKey}`;

      // Create system messages based on mode
      let defaultSystemMessages;
      let greetingMessage;

      if (mode === 'ranting') {
        // Ranting AI - focused on listening and emotional support
        defaultSystemMessages = [
          {
            parts: [
              {
                text: `You are Mena, a compassionate and empathetic emotional support companion. Your primary role is to LISTEN and provide emotional support, not to educate or give advice.

YOUR CORE PURPOSE:
- Listen actively and attentively to what the user is sharing
- Validate their feelings and emotions
- Provide emotional support and comfort
- Help them feel heard and understood
- Create a safe, non-judgmental space for expression

COMMUNICATION STYLE:
- Be warm, caring, and genuinely empathetic
- Use simple, conversational language
- Keep responses concise (2-3 sentences max for voice)
- Acknowledge their feelings: "I hear you...", "That sounds...", "It makes sense that..."
- Ask gentle follow-up questions to show you're listening
- Use their name when appropriate
- Be present and focused on THEM, not on giving solutions

WHAT TO DO:
1. Listen without interrupting
2. Validate their emotions - "Your feelings are valid"
3. Show empathy - "I can understand why you'd feel that way"
4. Ask clarifying questions - "Can you tell me more about...?"
5. Offer comfort - "I'm here for you"
6. Normalize their experience - "Many people feel this way"
7. Suggest they talk to someone if they're in crisis

WHAT NOT TO DO:
1. Don't try to "fix" their problems
2. Don't minimize their feelings
3. Don't give medical advice
4. Don't be judgmental
5. Don't rush to solutions
6. Don't make it about you

EXAMPLE RESPONSES:
- "That sounds really difficult. I'm glad you're sharing this with me. Tell me more about how you're feeling."
- "It's completely normal to feel overwhelmed right now. Your feelings matter."
- "I hear you. That must be really frustrating. How has this been affecting you?"
- "You're not alone in feeling this way. Many people experience similar emotions."

Remember: Your job is to LISTEN and SUPPORT, not to solve or educate. Be present, be kind, be human.`,
              },
            ],
            role: 'user',
          },
        ];
        greetingMessage = 'Hi! I\'m Mena, and I\'m here to listen. Whatever\'s on your mind, I\'m all ears. What would you like to talk about?';
      } else {
        // Education AI - focused on health education
        defaultSystemMessages = [
          {
            parts: [
              {
                text: `You are Mena, a friendly and knowledgeable health educator specializing in girls' and women's health. You provide educational information about:

TOPICS YOU SPECIALIZE IN:
- Menstrual cycles and period health
- PCOS (Polycystic Ovary Syndrome) - symptoms, management, lifestyle tips
- PCOD (Polycystic Ovarian Disease) - similar to PCOS, causes, treatments
- Endometriosis - what it is, symptoms, coping strategies
- Perimenopause - transition to menopause, symptoms, changes
- Menopause - what to expect, managing symptoms
- Pregnancy and reproductive health
- General women's wellness

COMMUNICATION STYLE:
- Use simple, everyday language - avoid complex medical jargon
- Be warm, friendly, and encouraging
- Keep responses concise (2-3 sentences max for voice)
- Use analogies and relatable examples
- Be inclusive and respectful of all experiences

IMPORTANT RULES:
1. NEVER give medical diagnoses or treatment recommendations
2. ALWAYS suggest consulting a doctor for health concerns
3. Provide educational information only
4. Stay on-topic about women's and girls' health
5. If asked about other topics, politely redirect to health topics
6. Be empathetic - many people feel embarrassed discussing these topics

EXAMPLE RESPONSES:
- "PCOS affects how your body produces hormones. Many people manage it with lifestyle changes and medical support. I'd recommend talking to your doctor about what's best for you."
- "Endometriosis can cause painful periods. It's important to see a healthcare provider who can help you manage the pain and explore treatment options."
- "Perimenopause is when your body transitions to menopause. Hot flashes and mood changes are common. Your doctor can help you manage these symptoms."

Remember: You're here to educate and support, not to diagnose or treat. Always encourage professional medical consultation.`,
              },
            ],
            role: 'user',
          },
        ];
        greetingMessage = 'Hi! I\'m Mena, your girls\' health educator. I\'m here to answer questions about periods, PCOS, PCOD, endometriosis, menopause, and more. What would you like to know?';
      }

      // Exact configuration format from Agora docs
      const requestBody = {
        name: agentName,
        properties: {
          channel: channelName,
          token: token,
          agent_rtc_uid: '999',
          remote_rtc_uids: ['*'], // Subscribe to ALL users in the channel
          idle_timeout: 120,
          // ASR Configuration - Agora Ares (exact format from docs)
          asr: {
            vendor: 'ares',
            language: 'en-US',
          },
          // TTS Configuration - Cartesia (exact format from docs)
          tts: {
            vendor: 'cartesia',
            params: {
              api_key: this.ttsApiKey,
              model_id: this.ttsModelId,
              voice: {
                mode: 'id',
                id: this.ttsVoiceId,
              },
              output_format: {
                container: 'raw',
                sample_rate: 16000,
              },
              language: 'en',
            },
          },
          // LLM Configuration - Google Gemini (exact format from docs)
          llm: {
            url: geminiUrl,
            system_messages: systemMessages || defaultSystemMessages,
            max_history: 32,
            greeting_message: greetingMessage,
            failure_message: 'Hold on a second.',
            params: {
              model: this.llmModel,
            },
            style: 'gemini',
          },
        },
      };

      console.log('📤 Request body:', JSON.stringify(requestBody, null, 2));

      const response = await axios.post(
        `${this.baseUrl}/projects/${this.appId}/join`,
        requestBody,
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json',
          },
        },
      );

      console.log('✅ Agent started successfully');
      console.log('📊 Agent ID:', response.data.agent_id);
      console.log('📊 Status:', response.data.status);
      
      return {
        success: true,
        agentId: response.data.agent_id,
        status: response.data.status,
        createdAt: response.data.create_ts,
      };
    } catch (error) {
      console.error('❌ Error starting agent:', error.message);
      if (error.response) {
        console.error('Response status:', error.response.status);
        console.error('Response data:', error.response.data);
        
        // Check for Gemini API quota/rate limit errors
        if (error.response.status === 429 || error.response.status === 403) {
          console.error('⚠️ GEMINI API QUOTA EXCEEDED or RATE LIMITED');
          console.error('💡 Solution: Check your Google Cloud Console for quota limits');
          console.error('💡 Your API key may need to be regenerated or quota increased');
        }
      }
      throw error;
    }
  }

  /**
   * Stop a conversational AI agent
   * @param {string} agentId - The agent ID to stop
   * @returns {Promise<Object>} Stop response
   */
  async stopAgent(agentId) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🛑 Stopping Agora Conversational AI agent: ${agentId}`);

      const response = await axios.post(
        `${this.baseUrl}/projects/${this.appId}/agents/${agentId}/leave`,
        {},
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json',
          },
        },
      );

      console.log('✅ Agent stopped successfully');
      return {
        success: true,
        message: 'Agent stopped',
      };
    } catch (error) {
      // Handle 404 - agent may have already been stopped by idle timeout
      if (error.response && error.response.status === 404) {
        console.warn('⚠️ Agent already stopped or not found (404)');
        return {
          success: true,
          message: 'Agent already stopped',
        };
      }

      console.error('❌ Error stopping agent:', error.message);
      if (error.response) {
        console.error('Response status:', error.response.status);
        console.error('Response data:', error.response.data);
      }
      throw error;
    }
  }

  /**
   * Query agent status
   * @param {string} agentId - The agent ID to query
   * @returns {Promise<Object>} Agent status
   */
  async queryAgentStatus(agentId) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      const response = await axios.get(
        `${this.baseUrl}/projects/${this.appId}/agents/${agentId}`,
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json',
          },
        },
      );

      return {
        success: true,
        agentId: response.data.agent_id,
        status: response.data.status,
        createdAt: response.data.create_ts,
      };
    } catch (error) {
      console.error('❌ Error querying agent status:', error.message);
      throw error;
    }
  }

  /**
   * Update agent configuration
   * @param {string} agentId - The agent ID to update
   * @param {Object} updates - Configuration updates
   * @returns {Promise<Object>} Update response
   */
  async updateAgent(agentId, updates) {
    try {
      if (!this.appId || !this.customerId || !this.customerSecret) {
        throw new Error('Agora credentials not configured');
      }

      console.log(`🔄 Updating agent: ${agentId}`);

      const response = await axios.patch(
        `${this.baseUrl}/projects/${this.appId}/agents/${agentId}`,
        { properties: updates },
        {
          headers: {
            Authorization: this._getAuthHeader(),
            'Content-Type': 'application/json',
          },
        },
      );

      console.log('✅ Agent updated successfully');
      return {
        success: true,
        agentId: response.data.agent_id,
        status: response.data.status,
      };
    } catch (error) {
      console.error('❌ Error updating agent:', error.message);
      throw error;
    }
  }

  /**
   * Get a greeting message from the AI
   * Uses pre-defined greetings to avoid rate limits
   * @param {string} mode - 'education' or 'ranting'
   * @returns {Promise<string>} Greeting message
   */
  async generateGreeting(mode = 'education') {
    try {
      // Use pre-defined greetings based on mode
      let greetings;

      if (mode === 'ranting') {
        // Ranting/emotional support greetings
        greetings = [
          'Hi! I\'m Mena, and I\'m here to listen. Whatever\'s on your mind, I\'m all ears. What would you like to talk about?',
          'Hello! I\'m Mena. I\'m here to listen and support you. Share whatever\'s on your heart.',
          'Hi there! I\'m Mena. I\'m all ears and ready to listen. What\'s going on?',
          'Welcome! I\'m Mena, and I\'m here for you. Feel free to share anything you\'re feeling.',
          'Hello! I\'m Mena. I\'m here to listen without judgment. What would you like to talk about?',
        ];
      } else {
        // Education greetings (default)
        greetings = [
          'Hi! I\'m Mena, your girls\' health educator. I can help with questions about periods, PCOS, PCOD, endometriosis, and menopause. What would you like to know?',
          'Welcome! I\'m Mena. I\'m here to provide friendly information about women\'s health topics. Feel free to ask me anything!',
          'Hello! I\'m Mena, your health companion. Whether you have questions about your cycle, PCOS, endometriosis, or perimenopause, I\'m here to help.',
          'Hi there! I\'m Mena. I specialize in girls\' and women\'s health education. What health topic can I help you understand today?',
          'Welcome to your health chat! I\'m Mena, and I\'m excited to help you learn about reproductive health and wellness. What\'s on your mind?',
        ];
      }

      // Select a random greeting
      const greeting = greetings[Math.floor(Math.random() * greetings.length)];

      console.log(`✅ Greeting selected (${mode}): ${greeting}`);
      return greeting;
    } catch (error) {
      console.error('❌ Error getting greeting:', error.message);

      // Return a default greeting based on mode
      if (mode === 'ranting') {
        return 'Hello! I\'m Mena, and I\'m here to listen. What\'s on your mind?';
      } else {
        return 'Hello! I\'m your health educator. Feel free to ask me anything about periods, menopause, or pregnancy.';
      }
    }
  }

  /**
   * Get service status
   * @returns {Object} Service status
   */
  getStatus() {
    return {
      service: 'agora_conversational_ai',
      configured:
        !!this.appId && !!this.customerId && !!this.customerSecret,
      appId: this.appId ? '***' : 'not_set',
      llmModel: this.llmModel,
      llmVendor: 'gemini',
      ttsVendor: 'cartesia',
      ttsModelId: this.ttsModelId,
      asrVendor: 'ares',
      asrNote: 'Using Agora built-in Ares STT',
      greetingType: 'Pre-defined (no API calls)',
    };
  }
}

module.exports = new AgoraConversationalAIService();
