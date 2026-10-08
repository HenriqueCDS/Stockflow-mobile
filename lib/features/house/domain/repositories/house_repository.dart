import '../entities/company_entity.dart';
import '../entities/member_entity.dart';

abstract interface class HouseRepository {
  Future<CompanyEntity> getCompany();
  Future<CompanyEntity> updateCompany(Map<String, dynamic> data);
  Future<List<MemberEntity>> getMembers();
  Future<void> removeMember(String userId);
  Future<String> rotateInviteCode();
}
