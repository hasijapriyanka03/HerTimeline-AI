// In-memory storage for demo purposes
// In production, use MongoDB with Mongoose schemas

const userPregnancies = new Map();

class UserPregnancy {
  constructor(data) {
    this.user_id = data.user_id;
    this.lmp_date = data.lmp_date;
    this.due_date = data.due_date;
    this.allergies = data.allergies || [];
    this.preferences = data.preferences || [];
    this.created_at = data.created_at || new Date().toISOString();
    this.updated_at = data.updated_at || new Date().toISOString();
  }

  static create(data) {
    const profile = new UserPregnancy(data);
    userPregnancies.set(data.user_id, profile);
    return profile;
  }

  static findByUserId(userId) {
    return userPregnancies.get(userId);
  }

  static update(userId, data) {
    const existing = userPregnancies.get(userId);
    if (!existing) return null;
    
    const updated = new UserPregnancy({
      ...existing,
      ...data,
      user_id: userId,
      updated_at: new Date().toISOString(),
    });
    
    userPregnancies.set(userId, updated);
    return updated;
  }
}

module.exports = UserPregnancy;
