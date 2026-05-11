import '../entities/general_report_entity.dart';
import '../repositories/report_repository.dart';

class GetGeneralReportUseCase {
  final ReportRepository _repository;
  const GetGeneralReportUseCase(this._repository);

  Future<GeneralReportEntity> call() => _repository.getGeneralReport();
}
