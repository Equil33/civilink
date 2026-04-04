class Commune {
  final int id;
  final String name;
  final String prefecture;

  Commune({
    required this.id,
    required this.name,
    required this.prefecture,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: json['id'],
      name: json['name'],
      prefecture: json['prefecture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prefecture': prefecture,
    };
  }
}