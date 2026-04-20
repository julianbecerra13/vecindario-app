class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es obligatorio';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener mínimo 2 caracteres';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 10) {
      return 'Ingresa un número de 10 dígitos';
    }
    return null;
  }

  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código es obligatorio';
    }
    if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(value)) {
      return 'El código debe tener 6 caracteres alfanuméricos';
    }
    return null;
  }

  static String? validateRequired(
    String? value, [
    String field = 'Este campo',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$field es obligatorio';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return null;
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price < 0) {
      return 'Ingresa un precio válido';
    }
    return null;
  }

  static String? validateTower(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La torre/bloque es obligatorio';
    }
    return null;
  }

  static String? validateApartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El apartamento es obligatorio';
    }
    return null;
  }
}
