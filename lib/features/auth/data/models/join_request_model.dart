class JoinRequestModel {
  final String name;
  final String email;
  final String password;
  final String inviteCode;

  const JoinRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.inviteCode,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'inviteCode': inviteCode,
      };
}
