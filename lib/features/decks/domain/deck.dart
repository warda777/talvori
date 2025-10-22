class Deck {
  final String id, name;
  final String? description;
  final DateTime createdAt;

  const Deck({required this.id, required this.name, this.description, required this.createdAt});

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
    id: j['id'], name: j['name'], description: j['description'],
    createdAt: DateTime.parse(j['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'created_at': createdAt.toIso8601String(),
  };
}
