class ScreenAuditInput {
  const ScreenAuditInput({
    this.hours,
    this.apps = const [],
    this.pickups,
  });

  final double? hours;
  final List<String> apps;
  final int? pickups;

  Map<String, dynamic> toJson() => {
        'hours': hours,
        'apps': apps,
        'pickups': pickups,
      };

  factory ScreenAuditInput.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ScreenAuditInput();
    return ScreenAuditInput(
      hours: (json['hours'] as num?)?.toDouble(),
      apps: (json['apps'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      pickups: (json['pickups'] as num?)?.toInt(),
    );
  }
}

class IfThenPair {
  const IfThenPair({required this.ifText, required this.thenText});

  final String ifText;
  final String thenText;

  Map<String, dynamic> toJson() => {'if': ifText, 'then': thenText};

  factory IfThenPair.fromJson(Map<String, dynamic> json) {
    return IfThenPair(
      ifText: json['if'] as String? ?? '',
      thenText: json['then'] as String? ?? '',
    );
  }
}

class ReplacementLists {
  const ReplacementLists({
    this.minutes5 = const [],
    this.minutes15 = const [],
    this.minutes60 = const [],
  });

  final List<String> minutes5;
  final List<String> minutes15;
  final List<String> minutes60;

  Map<String, dynamic> toJson() => {
        '5': minutes5,
        '15': minutes15,
        '60': minutes60,
      };

  factory ReplacementLists.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReplacementLists();
    List<String> listFor(String key) {
      return (json[key] as List? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false);
    }

    return ReplacementLists(
      minutes5: listFor('5'),
      minutes15: listFor('15'),
      minutes60: listFor('60'),
    );
  }
}

class UserInputs {
  const UserInputs({
    this.screenAudit,
    this.triggers = const [],
    this.whyStatement,
    this.replacements = const ReplacementLists(),
    this.ifThen = const [],
    this.relapsePlan,
    this.identity,
    this.rules = const [],
    this.futureLetter,
  });

  final ScreenAuditInput? screenAudit;
  final List<String> triggers;
  final String? whyStatement;
  final ReplacementLists replacements;
  final List<IfThenPair> ifThen;
  final String? relapsePlan;
  final String? identity;
  final List<String> rules;
  final String? futureLetter;

  UserInputs copyWith({
    ScreenAuditInput? screenAudit,
    List<String>? triggers,
    String? whyStatement,
    ReplacementLists? replacements,
    List<IfThenPair>? ifThen,
    String? relapsePlan,
    String? identity,
    List<String>? rules,
    String? futureLetter,
  }) {
    return UserInputs(
      screenAudit: screenAudit ?? this.screenAudit,
      triggers: triggers ?? this.triggers,
      whyStatement: whyStatement ?? this.whyStatement,
      replacements: replacements ?? this.replacements,
      ifThen: ifThen ?? this.ifThen,
      relapsePlan: relapsePlan ?? this.relapsePlan,
      identity: identity ?? this.identity,
      rules: rules ?? this.rules,
      futureLetter: futureLetter ?? this.futureLetter,
    );
  }

  Map<String, dynamic> toJson() => {
        'screenAudit': screenAudit?.toJson(),
        'triggers': triggers,
        'whyStatement': whyStatement,
        'replacements': replacements.toJson(),
        'ifThen': ifThen.map((e) => e.toJson()).toList(),
        'relapsePlan': relapsePlan,
        'identity': identity,
        'rules': rules,
        'futureLetter': futureLetter,
      };

  factory UserInputs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserInputs();
    return UserInputs(
      screenAudit: json['screenAudit'] != null
          ? ScreenAuditInput.fromJson(
              Map<String, dynamic>.from(json['screenAudit'] as Map),
            )
          : null,
      triggers: (json['triggers'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      whyStatement: json['whyStatement'] as String?,
      replacements: ReplacementLists.fromJson(
        Map<String, dynamic>.from(json['replacements'] as Map? ?? {}),
      ),
      ifThen: (json['ifThen'] as List? ?? const [])
          .map(
            (e) => IfThenPair.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(growable: false),
      relapsePlan: json['relapsePlan'] as String?,
      identity: json['identity'] as String?,
      rules: (json['rules'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(growable: false),
      futureLetter: json['futureLetter'] as String?,
    );
  }
}
