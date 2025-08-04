class Event {
  final int id;
  final String name;
  final String description;
  final String date;
  final String endDate;
  final String time;
  final String location;
  final int maxParticipants;
  final int currentParticipants;
  final String category;
  final double price;
  final int? creatorId;
  final String? imageUrl;
  final DateTime? createdAt;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.endDate,
    required this.time,
    required this.location,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.category,
    required this.price,
    this.creatorId,
    this.imageUrl,
    this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      description: _parseString(json['description']),
      date: _parseString(json['date']),
      endDate: _parseString(json['end_date']),
      time: _parseString(json['time']),
      location: _parseString(json['location']),
      maxParticipants: _parseInt(json['max_participants']),
      currentParticipants: _parseInt(json['current_participants']),
      category: _parseString(json['category']),
      price: _parseDouble(json['price']),
      creatorId: json['creator_id'] != null ? _parseInt(json['creator_id']) : null,
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'end_date': endDate,
      'time': time,
      'location': location,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'category': category,
      'price': price,
      if (creatorId != null) 'creator_id': creatorId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // Untuk kirim data saat membuat event (tanpa readonly fields)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'end_date': endDate,
      'time': time,
      'location': location,
      'max_participants': maxParticipants,
      'category': category,
      'price': price, //
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  // Helper parsing integer
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Helper parsing string
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  //
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
