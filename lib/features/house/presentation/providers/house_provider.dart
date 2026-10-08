// Carrega a casa (company) + lista de membros juntos, já que a tela "Minha casa"
// sempre exibe ambos.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/house_remote_datasource.dart';
import '../../data/repositories/house_repository_impl.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/house_usecases.dart';

final _houseDsProvider = Provider(
  (ref) => HouseRemoteDataSourceImpl(ref.read(dioProvider)),
);

final houseRepoProvider = Provider(
  (ref) => HouseRepositoryImpl(ref.read(_houseDsProvider)),
);

class HouseState {
  final CompanyEntity company;
  final List<MemberEntity> members;

  const HouseState({required this.company, required this.members});

  HouseState copyWith({CompanyEntity? company, List<MemberEntity>? members}) =>
      HouseState(
        company: company ?? this.company,
        members: members ?? this.members,
      );
}

final houseProvider =
    AsyncNotifierProvider<HouseNotifier, HouseState>(HouseNotifier.new);

class HouseNotifier extends AsyncNotifier<HouseState> {
  @override
  Future<HouseState> build() => _loadAll();

  Future<HouseState> _loadAll() async {
    final repo = ref.read(houseRepoProvider);
    final company = await GetCompanyUseCase(repo)();
    final members = await GetMembersUseCase(repo)();
    return HouseState(company: company, members: members);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadAll);
  }

  Future<void> updateCompany(Map<String, dynamic> data) async {
    final repo = ref.read(houseRepoProvider);
    final updated = await UpdateCompanyUseCase(repo)(data);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(company: updated));
    }
  }

  Future<void> removeMember(String userId) async {
    final repo = ref.read(houseRepoProvider);
    await RemoveMemberUseCase(repo)(userId);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        members: current.members.where((m) => m.id != userId).toList(),
      ));
    }
  }

  Future<void> rotateInviteCode() async {
    final repo = ref.read(houseRepoProvider);
    final newCode = await RotateInviteCodeUseCase(repo)();
    final current = state.valueOrNull;
    if (current != null) {
      final company = current.company;
      state = AsyncData(current.copyWith(
        company: CompanyEntity(
          id: company.id,
          name: company.name,
          tenantId: company.tenantId,
          inviteCode: newCode,
          email: company.email,
          phone: company.phone,
          address: company.address,
          active: company.active,
          createdAt: company.createdAt,
        ),
      ));
    }
  }
}
