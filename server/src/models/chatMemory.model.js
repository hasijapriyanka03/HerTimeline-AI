const chatMemories = new Map();

class ChatMemory {
  constructor(userId) {
    this.user_id = userId;
    this.messages = [];
  }

  static getOrCreate(userId) {
    if (!chatMemories.has(userId)) {
      chatMemories.set(userId, new ChatMemory(userId));
    }
    return chatMemories.get(userId);
  }

  static addMessage(userId, role, content) {
    const memory = ChatMemory.getOrCreate(userId);
    memory.messages.push({
      role,
      content,
      timestamp: new Date().toISOString(),
    });
    
    // Keep only last 20 messages
    if (memory.messages.length > 20) {
      memory.messages = memory.messages.slice(-20);
    }
    
    return memory;
  }

  static getMessages(userId) {
    const memory = chatMemories.get(userId);
    return memory ? memory.messages : [];
  }
}

module.exports = ChatMemory;
