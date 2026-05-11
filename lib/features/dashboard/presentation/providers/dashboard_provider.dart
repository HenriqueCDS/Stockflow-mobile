// Migrado de: src/pages/Dashboard.jsx + src/pages/Reports.jsx
// useState(report) + useEffect(reportApi.getGeneralReport()) → AsyncNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homestock_mobile/core/di/core_providers.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/general_report_entity.dart';
import '../../domain/usecases/get_general_report_usecase.dart';

final _reportDsProvider = Provider(
  (ref) => ReportRemoteDataSourceImpl(ref.read(dioProvider)),
);

final _reportRepoProvider = Provider(
  (ref) => ReportRepositoryImpl(ref.read(_reportDsProvider)),
);

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, GeneralReportEntity>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<GeneralReportEntity> {
  @override
  Future<GeneralReportEntity> build() => _fetch();

  Future<GeneralReportEntity> _fetch() {
    final useCase = GetGeneralReportUseCase(ref.read(_reportRepoProvider));
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
