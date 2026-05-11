sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('Sem conexão com o servidor. Verifique sua rede.');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure()
      : super('Sessão expirada. Faça login novamente.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
