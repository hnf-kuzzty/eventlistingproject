class User {
  final int id;
  final String name;
  final String email;
  final String studentNumber;
  final String major;
  final int classYear;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.studentNumber,
    required this.major,
    required this.classYear,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      email: _parseString(json['email']),
      studentNumber: _parseString(json['student_number']),
      major: _parseString(json['major']),
      classYear: _parseInt(json['class_year']),
    );
  }

  // Safe integer parsing method
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  // Safe string parsing method
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'student_number': studentNumber,
      'major': major,
      'class_year': classYear,
    };
  }
}