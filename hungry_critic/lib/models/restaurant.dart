class Restaurant {
  Restaurant({
    required this.id,
    required this.owner,
    required this.name,
    this.address,
    required this.timestamp,
  });

  final String id;

  late String owner;

  final String name;

  final String? address;

  final DateTime timestamp;
}
