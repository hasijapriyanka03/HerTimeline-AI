class FoodItem {
  final String name;
  final List<String> nutrients;
  final List<String> avoidIfAllergic;

  FoodItem({
    required this.name,
    required this.nutrients,
    required this.avoidIfAllergic,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      nutrients: List<String>.from(json['nutrients'] ?? []),
      avoidIfAllergic: List<String>.from(json['avoid_if_allergic'] ?? []),
    );
  }

  bool isSafeFor(List<String> userAllergies) {
    return !avoidIfAllergic.any(
      (allergen) => userAllergies.any(
        (userAllergen) => userAllergen.toLowerCase() == allergen.toLowerCase(),
      ),
    );
  }
}
