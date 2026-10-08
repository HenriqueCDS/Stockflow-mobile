// Espelha InviteCodeResponseDTO (POST /api/v1/company/invite-code/rotate).
class InviteCodeModel {
  final String inviteCode;

  const InviteCodeModel({required this.inviteCode});

  factory InviteCodeModel.fromJson(Map<String, dynamic> json) =>
      InviteCodeModel(inviteCode: json['inviteCode'] as String? ?? '');
}
