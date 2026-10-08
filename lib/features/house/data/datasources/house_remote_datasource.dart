// GET    /api/v1/company                     → ApiResponseDTO<CompanyResponseDTO>
// PUT    /api/v1/company                      → ApiResponseDTO<CompanyResponseDTO>
// GET    /api/v1/company/members              → ApiResponseDTO<List<MemberResponseDTO>>
// DELETE /api/v1/company/members/{userId}     → 204, só OWNER
// POST   /api/v1/company/invite-code/rotate   → ApiResponseDTO<InviteCodeResponseDTO>, só OWNER
import 'package:dio/dio.dart';
import 'package:homestock_mobile/core/network/api_interceptors.dart';
import 'package:homestock_mobile/core/network/api_response.dart';
import '../models/company_model.dart';
import '../models/member_model.dart';
import '../models/invite_code_model.dart';

abstract interface class HouseRemoteDataSource {
  Future<CompanyModel> getCompany();
  Future<CompanyModel> updateCompany(Map<String, dynamic> data);
  Future<List<MemberModel>> getMembers();
  Future<void> removeMember(String userId);
  Future<InviteCodeModel> rotateInviteCode();
}

class HouseRemoteDataSourceImpl implements HouseRemoteDataSource {
  final Dio _dio;
  HouseRemoteDataSourceImpl(this._dio);

  @override
  Future<CompanyModel> getCompany() async {
    try {
      final res = await _dio.get('/company');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        CompanyModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<CompanyModel> updateCompany(Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('/company', data: data);
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        CompanyModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<List<MemberModel>> getMembers() async {
    try {
      final res = await _dio.get('/company/members');
      final json = res.data as Map<String, dynamic>;
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<void> removeMember(String userId) async {
    try {
      await _dio.delete('/company/members/$userId');
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }

  @override
  Future<InviteCodeModel> rotateInviteCode() async {
    try {
      final res = await _dio.post('/company/invite-code/rotate');
      return unwrapApiResponse(
        res.data as Map<String, dynamic>,
        InviteCodeModel.fromJson,
      );
    } on DioException catch (e) {
      throw dioErrorToFailure(e);
    }
  }
}
