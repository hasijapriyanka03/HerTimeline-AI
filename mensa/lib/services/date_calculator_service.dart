class DateCalculatorService {
  // Calculate due date from LMP (Last Menstrual Period)
  static DateTime calculateDueDateFromLMP(DateTime lmpDate) {
    // Naegele's rule: Add 280 days (40 weeks) to LMP
    return lmpDate.add(const Duration(days: 280));
  }

  // Calculate LMP from due date
  static DateTime calculateLMPFromDueDate(DateTime dueDate) {
    return dueDate.subtract(const Duration(days: 280));
  }

  // Calculate current pregnancy week
  static int calculateCurrentWeek(DateTime lmpDate) {
    final now = DateTime.now();
    final difference = now.difference(lmpDate).inDays;
    return (difference / 7).floor();
  }

  // Calculate trimester
  static int calculateTrimester(int week) {
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  // Calculate days until due date
  static int daysUntilDueDate(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }

  // Format week display (e.g., "Week 8 of 40")
  static String formatWeekDisplay(int week) {
    return 'Week $week of 40';
  }

  // Get trimester name
  static String getTrimesterName(int trimester) {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return 'Unknown';
    }
  }
}
