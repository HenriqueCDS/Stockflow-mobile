import '../entities/company_entity.dart';
import '../entities/member_entity.dart';
import '../repositories/house_repository.dart';

class GetCompanyUseCase {
  final HouseRepository _r;
  const GetCompanyUseCase(this._r);
  Future<CompanyEntity> call() => _r.getCompany();
}

class UpdateCompanyUseCase {
  final HouseRepository _r;
  const UpdateCompanyUseCase(this._r);
  Future<CompanyEntity> call(Map<String, dynamic> data) =>
      _r.updateCompany(data);
}

class GetMembersUseCase {
  final HouseRepository _r;
  const GetMembersUseCase(this._r);
  Future<List<MemberEntity>> call() => _r.getMembers();
}

class RemoveMemberUseCase {
  final HouseRepository _r;
  const RemoveMemberUseCase(this._r);
  Future<void> call(String userId) => _r.removeMember(userId);
}

class RotateInviteCodeUseCase {
  final HouseRepository _r;
  const RotateInviteCodeUseCase(this._r);
  Future<String> call() => _r.rotateInviteCode();
}
