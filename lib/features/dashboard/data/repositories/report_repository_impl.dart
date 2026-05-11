import '../../domain/entities/general_report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _ds;
  ReportRepositoryImpl(this._ds);

  @override
  Future<GeneralReportEntity> getGeneralReport() async {
    final model = await _ds.getGeneralReport();
    return model.toEntity();
  }
}
