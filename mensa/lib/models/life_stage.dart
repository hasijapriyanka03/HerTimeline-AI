enum LifeStage {
  stage1, // "Wait, What's This?" (8-12)
  stage2, // "Here We Go..." (12-16)
  stage3, // "Adulting Unlocked" (16-25)
  stage4, // "Trying for a Baby" (18-40)
  stage5, // "Pregnant & Winging It"
  stage6, // "Wait, Where's My Body?" (Postpartum)
  stage7, // "Chaos Continues" (25-40)
  stage8, // "Is This Perimenopause?" (35-55)
  stage9, // "The Other Side" (50+)
}

extension LifeStageExtension on LifeStage {
  String get displayName {
    switch (this) {
      case LifeStage.stage1:
        return "Wait, What's This?";
      case LifeStage.stage2:
        return "Here We Go...";
      case LifeStage.stage3:
        return "Adulting Unlocked";
      case LifeStage.stage4:
        return "Trying for a Baby";
      case LifeStage.stage5:
        return "Pregnant & Winging It";
      case LifeStage.stage6:
        return "Wait, Where's My Body?";
      case LifeStage.stage7:
        return "Chaos Continues";
      case LifeStage.stage8:
        return "Is This Perimenopause?";
      case LifeStage.stage9:
        return "The Other Side";
    }
  }

  String get description {
    switch (this) {
      case LifeStage.stage1:
        return "Ages 8-12: Friendly curiosity, zero judgment";
      case LifeStage.stage2:
        return "Ages 12-16: Real talk, relatable, witty";
      case LifeStage.stage3:
        return "Ages 16-25: Sarcasm, strategy, empowering";
      case LifeStage.stage4:
        return "Ages 18-40: Hopeful, strategic, detailed";
      case LifeStage.stage5:
        return "Pregnancy: Excited, nervous, detailed";
      case LifeStage.stage6:
        return "Postpartum: Real, urgent, compassionate";
      case LifeStage.stage7:
        return "Ages 25-40: Sarcastic, strategic, burnout-alert";
      case LifeStage.stage8:
        return "Ages 35-55: Detective mode, validating";
      case LifeStage.stage9:
        return "Ages 50+: Wise, witty, self-care-focused";
    }
  }

  String get emoji {
    switch (this) {
      case LifeStage.stage1:
        return "🤔";
      case LifeStage.stage2:
        return "😊";
      case LifeStage.stage3:
        return "💪";
      case LifeStage.stage4:
        return "💕";
      case LifeStage.stage5:
        return "🤰";
      case LifeStage.stage6:
        return "👶";
      case LifeStage.stage7:
        return "🔥";
      case LifeStage.stage8:
        return "🌡️";
      case LifeStage.stage9:
        return "✨";
    }
  }

  int get minAge {
    switch (this) {
      case LifeStage.stage1:
        return 8;
      case LifeStage.stage2:
        return 12;
      case LifeStage.stage3:
        return 16;
      case LifeStage.stage4:
        return 18;
      case LifeStage.stage5:
        return 18;
      case LifeStage.stage6:
        return 18;
      case LifeStage.stage7:
        return 25;
      case LifeStage.stage8:
        return 35;
      case LifeStage.stage9:
        return 50;
    }
  }

  int get maxAge {
    switch (this) {
      case LifeStage.stage1:
        return 12;
      case LifeStage.stage2:
        return 16;
      case LifeStage.stage3:
        return 25;
      case LifeStage.stage4:
        return 40;
      case LifeStage.stage5:
        return 45;
      case LifeStage.stage6:
        return 45;
      case LifeStage.stage7:
        return 40;
      case LifeStage.stage8:
        return 55;
      case LifeStage.stage9:
        return 120;
    }
  }

  List<String> get trackingFields {
    switch (this) {
      case LifeStage.stage1:
        return [
          'day_vibe',
          'body_changes',
          'mood',
          'energy',
          'physical_changes',
        ];
      case LifeStage.stage2:
        return [
          'pain_level',
          'mood',
          'stress',
          'body_map',
          'triggers',
          'period_bingo',
        ];
      case LifeStage.stage3:
        return [
          'pain_level',
          'mood',
          'stress',
          'energy',
          'sleep',
          'work_stress',
          'triggers',
        ];
      case LifeStage.stage4:
        return [
          'cycle_day',
          'cervical_fluid',
          'basal_temp',
          'sex_timing',
          'emotional_state',
          'ovulation_signs',
        ];
      case LifeStage.stage5:
        return [
          'trimester',
          'symptoms',
          'baby_movement',
          'contractions',
          'mood',
          'energy',
          'sleep',
        ];
      case LifeStage.stage6:
        return [
          'bleeding',
          'pain',
          'stitches_healing',
          'sleep',
          'energy',
          'mood',
          'mental_health',
          'baby_needs',
        ];
      case LifeStage.stage7:
        return [
          'cycle',
          'pain',
          'mood',
          'energy',
          'sleep',
          'work_stress',
          'parenting_load',
          'relationship_vibes',
          'burnout_meter',
        ];
      case LifeStage.stage8:
        return [
          'hot_flashes',
          'night_sweats',
          'mood_swings',
          'sleep',
          'joint_pain',
          'bleeding_changes',
          'memory_issues',
          'libido',
        ];
      case LifeStage.stage9:
        return [
          'hot_flashes',
          'mood',
          'sleep',
          'joint_pain',
          'bone_health',
          'heart_health',
          'libido',
          'identity',
        ];
    }
  }

  bool get requiresGuardianLink {
    return this == LifeStage.stage1 || this == LifeStage.stage2;
  }

  bool get isPregnancy {
    return this == LifeStage.stage5;
  }

  bool get isPostpartum {
    return this == LifeStage.stage6;
  }

  bool get isFertility {
    return this == LifeStage.stage4;
  }

  bool get isPerimenopause {
    return this == LifeStage.stage8;
  }

  bool get isMenopause {
    return this == LifeStage.stage9;
  }

  static LifeStage detectFromAge(int age) {
    if (age >= 8 && age < 12) return LifeStage.stage1;
    if (age >= 12 && age < 16) return LifeStage.stage2;
    if (age >= 16 && age < 25) return LifeStage.stage3;
    if (age >= 25 && age < 35) return LifeStage.stage7;
    if (age >= 35 && age < 50) return LifeStage.stage8;
    if (age >= 50) return LifeStage.stage9;
    return LifeStage.stage3; // Default
  }

  static LifeStage? detectFromPregnancyStatus(
    bool isPregnant,
    bool isPostpartum,
  ) {
    if (isPregnant) return LifeStage.stage5;
    if (isPostpartum) return LifeStage.stage6;
    return null;
  }
}
