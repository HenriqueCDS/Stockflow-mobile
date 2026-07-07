// GET /api/v1/dashboard → ApiResponseDTO<DashboardDTO>
// Substitui o antigo /stock/reports/general, que não existe mais na API.
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/dashboard_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;
  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<DashboardModel> getDashboard() async {
    try {
      final res = await _dio.get('/dashboard');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        DashboardModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
