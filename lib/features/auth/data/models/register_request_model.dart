class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String houseName;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.houseName,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'houseName': houseName,
      };
}
