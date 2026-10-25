const dailyLogs = new Map();

class DailyLog {
  constructor(data) {
    this.log_id = data.log_id || `log_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.user_id = data.user_id;
    this.date = data.date;
    this.mood = data.mood;
    this.symptoms = data.symptoms || [];
    this.water = data.water || 0;
    this.weight = data.weight || 0;
  }

  static create(data) {
    const log = new DailyLog(data);
    
    if (!dailyLogs.has(data.user_id)) {
      dailyLogs.set(data.user_id, []);
    }
    
    dailyLogs.get(data.user_id).push(log);
    return log;
  }

  static findByUserId(userId) {
    return dailyLogs.get(userId) || [];
  }

  static findByUserIdAndDateRange(userId, startDate, endDate) {
    const logs = dailyLogs.get(userId) || [];
    return logs.filter(log => {
      const logDate = new Date(log.date);
      return logDate >= new Date(startDate) && logDate <= new Date(endDate);
    });
  }
}

module.exports = DailyLog;
