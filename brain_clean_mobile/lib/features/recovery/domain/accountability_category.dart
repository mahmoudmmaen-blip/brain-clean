import 'package:flutter/material.dart' show IconData, Icons;

import '../../../core/l10n/app_localizations.dart';

/// Accountability room penalty categories (2×2 grid).
enum AccountabilityCategory {
  physical,
  nutritional,
  altruistic,
  mental,
}

extension AccountabilityCategoryX on AccountabilityCategory {
  String title(AppLocalizations loc) => switch (this) {
        AccountabilityCategory.physical => loc.accountabilityCatPhysical,
        AccountabilityCategory.nutritional => loc.accountabilityCatNutritional,
        AccountabilityCategory.altruistic => loc.accountabilityCatAltruistic,
        AccountabilityCategory.mental => loc.accountabilityCatMental,
      };

  IconData get icon => switch (this) {
        AccountabilityCategory.physical => Icons.fitness_center_outlined,
        AccountabilityCategory.nutritional => Icons.restaurant_outlined,
        AccountabilityCategory.altruistic => Icons.volunteer_activism_outlined,
        AccountabilityCategory.mental => Icons.psychology_outlined,
      };

  int penaltyGlobalIndex(int optionIndex) => index * 5 + optionIndex;

  String penaltyLabel(AppLocalizations loc, int optionIndex) {
    final labels = switch (this) {
      AccountabilityCategory.physical => [
        loc.accountabilityPenPhysical1,
        loc.accountabilityPenPhysical2,
        loc.accountabilityPenPhysical3,
        loc.accountabilityPenPhysical4,
        loc.accountabilityPenPhysical5,
      ],
      AccountabilityCategory.nutritional => [
        loc.accountabilityPenNutritional1,
        loc.accountabilityPenNutritional2,
        loc.accountabilityPenNutritional3,
        loc.accountabilityPenNutritional4,
        loc.accountabilityPenNutritional5,
      ],
      AccountabilityCategory.altruistic => [
        loc.accountabilityPenAltruistic1,
        loc.accountabilityPenAltruistic2,
        loc.accountabilityPenAltruistic3,
        loc.accountabilityPenAltruistic4,
        loc.accountabilityPenAltruistic5,
      ],
      AccountabilityCategory.mental => [
        loc.accountabilityPenMental1,
        loc.accountabilityPenMental2,
        loc.accountabilityPenMental3,
        loc.accountabilityPenMental4,
        loc.accountabilityPenMental5,
      ],
    };
    return labels[optionIndex.clamp(0, 4)];
  }
}
