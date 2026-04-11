abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($message)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure('No existe una cuenta con este correo.');
      case 'wrong-password':
        return const AuthFailure('Contraseña incorrecta.');
      case 'email-already-in-use':
        return const AuthFailure('Ya existe una cuenta con este correo.');
      case 'weak-password':
        return const AuthFailure('La contraseña es muy débil. Usa mínimo 8 caracteres.');
      case 'invalid-email':
        return const AuthFailure('El correo electrónico no es válido.');
      case 'user-disabled':
        return const AuthFailure('Esta cuenta ha sido deshabilitada.');
      case 'too-many-requests':
        return const AuthFailure('Demasiados intentos. Intenta de nuevo más tarde.');
      case 'invalid-credential':
        return const AuthFailure('Credenciales inválidas. Verifica tu correo y contraseña.');
      default:
        return AuthFailure('Error de autenticación: $code');
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet. Verifica tu red.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
