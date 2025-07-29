import '../../domain/entities/client.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phone,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] as String,
      email: map['email'] as String,
      firstName: map['user_metadata']['first_name'] as String,
      lastName: map['user_metadata']['last_name'] as String,
      phone: map['user_metadata']['phone'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      },
    };
  }
}
