class Validators {
  static String? requiredField(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Correo invalido';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.length < length) {
      return 'Debe tener al menos $length caracteres';
    }
    return null;
  }
}
