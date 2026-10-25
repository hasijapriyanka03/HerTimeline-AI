const fs = require('fs');
const path = require('path');

class NutritionEngine {
  constructor() {
    this.foods = this.loadFoods();
  }

  loadFoods() {
    try {
      const dataPath = path.join(__dirname, '../data/foods.json');
      return JSON.parse(fs.readFileSync(dataPath, 'utf8'));
    } catch (error) {
      console.error('Error loading foods:', error);
      return [];
    }
  }

  getRecommendations(week, userAllergies = []) {
    const trimester = this.calculateTrimester(week);
    
    const recommendations = {
      trimester,
      week,
      advice: this.getTrimesterAdvice(trimester),
      foods: this.foods.map(food => ({
        ...food,
        isSafe: this.isSafeForUser(food, userAllergies),
        allergyWarning: this.getAllergyWarning(food, userAllergies),
      })),
      keyNutrients: this.getKeyNutrients(trimester),
    };

    return recommendations;
  }

  calculateTrimester(week) {
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  isSafeForUser(food, userAllergies) {
    if (!food.avoid_if_allergic || food.avoid_if_allergic.length === 0) {
      return true;
    }

    return !food.avoid_if_allergic.some(allergen =>
      userAllergies.some(userAllergen =>
        userAllergen.toLowerCase() === allergen.toLowerCase()
      )
    );
  }

  getAllergyWarning(food, userAllergies) {
    if (!food.avoid_if_allergic || food.avoid_if_allergic.length === 0) {
      return null;
    }

    const matchedAllergies = food.avoid_if_allergic.filter(allergen =>
      userAllergies.some(userAllergen =>
        userAllergen.toLowerCase() === allergen.toLowerCase()
      )
    );

    if (matchedAllergies.length > 0) {
      return `⚠️ Contains: ${matchedAllergies.join(', ')}`;
    }

    return null;
  }

  getTrimesterAdvice(trimester) {
    const advice = {
      1: 'First Trimester: Focus on folic acid (400-800 mcg daily), iron, and protein. Eat small, frequent meals to manage nausea. Stay hydrated.',
      2: 'Second Trimester: Increase calcium (1000 mg daily) and vitamin D for baby\'s bone development. Continue iron and protein intake. You may need about 300 extra calories per day.',
      3: 'Third Trimester: Boost iron and protein as baby gains weight rapidly. Eat fiber-rich foods to prevent constipation. Stay well-hydrated and eat smaller, more frequent meals.',
    };

    return advice[trimester] || 'Maintain a balanced, nutritious diet throughout pregnancy.';
  }

  getKeyNutrients(trimester) {
    const nutrients = {
      1: ['Folic Acid', 'Iron', 'Protein', 'Vitamin B12', 'Vitamin D'],
      2: ['Calcium', 'Vitamin D', 'Iron', 'Protein', 'Omega-3 fatty acids'],
      3: ['Iron', 'Protein', 'Calcium', 'Fiber', 'Vitamin C'],
    };

    return nutrients[trimester] || [];
  }
}

module.exports = new NutritionEngine();
