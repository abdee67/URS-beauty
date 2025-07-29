class Client {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final int phone;

  Client({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }
}
