class ConsensusMenu {
  final String starter;
  final String main;
  final String alternative;
  final String dessert;
  final String explanation;
  final String adjustmentA;
  final String adjustmentB;

  const ConsensusMenu({
    required this.starter,
    required this.main,
    required this.alternative,
    required this.dessert,
    required this.explanation,
    required this.adjustmentA,
    required this.adjustmentB,
  });

  factory ConsensusMenu.fromJson(Map<String, dynamic> json) {
    return ConsensusMenu(
      starter: (json['starter'] ?? json['entree'] ?? '').toString(),
      main: (json['main'] ?? json['plat'] ?? '').toString(),
      alternative: (json['alternative'] ?? '').toString(),
      dessert: (json['dessert'] ?? '').toString(),
      explanation: (json['explanation'] ?? json['explication'] ?? '').toString(),
      adjustmentA: (json['adjustmentA'] ?? json['ajustementA'] ?? '').toString(),
      adjustmentB: (json['adjustmentB'] ?? json['ajustementB'] ?? '').toString(),
    );
  }
}
