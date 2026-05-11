import '../entities/general_report_entity.dart';

abstract interface class ReportRepository {
  Future<GeneralReportEntity> getGeneralReport();
}
