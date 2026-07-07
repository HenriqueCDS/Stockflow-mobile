// A API sempre envelopa respostas em ApiResponseDTO<T>:
// { success, message, data, errors, timestamp }
import '../errors/failures.dart';

T unwrapApiResponse<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) fromJson,
) {
  final data = json['data'];
  if (json['success'] == false || data == null) {
    throw ValidationFailure(
      json['message'] as String? ?? 'Erro na requisição.',
    );
  }
  return fromJson(data as Map<String, dynamic>);
}
