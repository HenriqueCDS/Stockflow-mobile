// Migrado de: src/api/api.js → reportApi.getGeneralReport()
// GET /api/v1/stock/reports/general
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import '../models/general_report_model.dart';

abstract interface class ReportRemoteDataSource {
  Future<GeneralReportModel> getGeneralReport();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final Dio _dio;
  ReportRemoteDataSourceImpl(this._dio);

  @override
  Future<GeneralReportModel> getGeneralReport() async {
    try {
      final res = await _dio.get('/stock/reports/general');
      return GeneralReportModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
