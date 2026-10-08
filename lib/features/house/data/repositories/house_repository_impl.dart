import '../../domain/entities/company_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/house_repository.dart';
import '../datasources/house_remote_datasource.dart';

class HouseRepositoryImpl implements HouseRepository {
  final HouseRemoteDataSource _ds;
  HouseRepositoryImpl(this._ds);

  @override
  Future<CompanyEntity> getCompany() async {
    final model = await _ds.getCompany();
    return model.toEntity();
  }

  @override
  Future<CompanyEntity> updateCompany(Map<String, dynamic> data) async {
    final model = await _ds.updateCompany(data);
    return model.toEntity();
  }

  @override
  Future<List<MemberEntity>> getMembers() async {
    final models = await _ds.getMembers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> removeMember(String userId) => _ds.removeMember(userId);

  @override
  Future<String> rotateInviteCode() async {
    final model = await _ds.rotateInviteCode();
    return model.inviteCode;
  }
}
