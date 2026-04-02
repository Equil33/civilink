class Quartier {
  final int id;
  final String name;
  final int communeId;

  Quartier({
    required this.id,
    required this.name,
    required this.communeId,
  });

  factory Quartier.fromJson(Map<String, dynamic> json) {
    // Handle both formats: communeId directly or nested in commune object
    int communeId;
    if (json['communeId'] != null) {
      communeId = json['communeId'] as int;
    } else if (json['commune'] != null && json['commune'] is Map) {
      communeId = (json['commune'] as Map<String, dynamic>)['id'] as int? ?? 1;
    } else {
      communeId = 1; // Default fallback
    }
    
    return Quartier(
      id: json['id'] as int,
      name: json['name'] as String,
      communeId: communeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'communeId': communeId,
    };
  }
}