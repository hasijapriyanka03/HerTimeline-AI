const fs = require('fs');
const path = require('path');

class SymptomAnalyzer {
  constructor() {
    this.symptomMap = this.loadSymptomMap();
  }

  loadSymptomMap() {
    try {
      const dataPath = path.join(__dirname, '../data/symptom_week_map.json');
      return JSON.parse(fs.readFileSync(dataPath, 'utf8'));
    } catch (error) {
      console.error('Error loading symptom map:', error);
      return {};
    }
  }

  async analyze(symptoms, week) {
    const weekKey = `week_${week}`;
    const weekData = this.symptomMap[weekKey];

    if (!weekData) {
      return {
        classification: 'unknown',
        guidance: 'Week data not available. Please consult your healthcare provider.',
        disclaimer: this.getDisclaimer(),
      };
    }

    // Normalize symptoms for comparison
    const normalizedSymptoms = symptoms.map(s => s.toLowerCase().trim());

    // Check for critical symptoms
    const criticalMatches = weekData.critical.filter(critical =>
      normalizedSymptoms.some(symptom => symptom.includes(critical.toLowerCase()))
    );

    if (criticalMatches.length > 0) {
      return {
        classification: 'critical',
        matchedSymptoms: criticalMatches,
        guidance: `⚠️ URGENT: You reported ${criticalMatches.join(', ')}. These are serious symptoms that require immediate medical attention. Please contact your healthcare provider or go to the emergency room right away.`,
        disclaimer: this.getDisclaimer(),
        seekDoctor: true,
      };
    }

    // Check for warning symptoms
    const warningMatches = weekData.warning.filter(warning =>
      normalizedSymptoms.some(symptom => symptom.includes(warning.toLowerCase()))
    );

    if (warningMatches.length > 0) {
      return {
        classification: 'warning',
        matchedSymptoms: warningMatches,
        guidance: `⚠️ WATCH OUT: You reported ${warningMatches.join(', ')}. While these may not be emergencies, they should be monitored closely. Contact your healthcare provider if symptoms persist or worsen.`,
        disclaimer: this.getDisclaimer(),
        seekDoctor: true,
      };
    }

    // Check for common symptoms
    const commonMatches = weekData.common.filter(common =>
      normalizedSymptoms.some(symptom => symptom.includes(common.toLowerCase()))
    );

    if (commonMatches.length > 0) {
      return {
        classification: 'common',
        matchedSymptoms: commonMatches,
        guidance: `✓ COMMON: ${commonMatches.join(', ')} are typical symptoms for week ${week} of pregnancy. Stay hydrated, rest when needed, and maintain a healthy diet. If symptoms become severe, contact your healthcare provider.`,
        disclaimer: this.getDisclaimer(),
        seekDoctor: false,
      };
    }

    // Unmatched symptoms
    return {
      classification: 'unmatched',
      guidance: `The symptoms you reported don't match our common patterns for week ${week}. This doesn't necessarily mean something is wrong, but it's a good idea to discuss them with your healthcare provider at your next appointment.`,
      disclaimer: this.getDisclaimer(),
      seekDoctor: false,
    };
  }

  getDisclaimer() {
    return '⚕️ DISCLAIMER: This analysis is for informational purposes only and does not replace professional medical advice. Always consult your healthcare provider for medical concerns.';
  }
}

module.exports = new SymptomAnalyzer();
