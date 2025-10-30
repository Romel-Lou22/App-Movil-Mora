/// Clase con validadores reutilizables para formularios
class Validators {
  // Constructor privado para evitar instanciación
  Validators._();

  // === Validador de Email ===

  /// Valida que el email tenga un formato correcto
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    // Expresión regular para validar email
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un email válido';
    }

    return null; // Email válido
  }

  // === Validador de Contraseña ===

  /// Valida que la contraseña tenga al menos 6 caracteres
  /// Retorna null si es válida, o un mensaje de error si no lo es
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null; // Contraseña válida
  }

  /// Valida que la contraseña sea fuerte
  /// (al menos 8 caracteres, mayúsculas, minúsculas y números)
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Al menos una mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }

    // Al menos una minúscula
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }

    // Al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }

    return null; // Contraseña fuerte
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != originalPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null; // Contraseñas coinciden
  }

  // === Validador de Campo Requerido ===

  /// Valida que un campo no esté vacío
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }

    return null; // Campo válido
  }

  // === Validador de Longitud Mínima ===

  /// Valida que un campo tenga una longitud mínima
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }

    if (value.length < min) {
      return fieldName != null
          ? '$fieldName debe tener al menos $min caracteres'
          : 'Debe tener al menos $min caracteres';
    }

    return null; // Longitud válida
  }

  // === Validador de Longitud Máxima ===

  /// Valida que un campo no exceda una longitud máxima
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return fieldName != null
          ? '$fieldName no debe exceder $max caracteres'
          : 'No debe exceder $max caracteres';
    }

    return null; // Longitud válida
  }

  // === Validador de Número ===

  /// Valida que un campo sea un número válido
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }

    if (double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName debe ser un número válido'
          : 'Debe ser un número válido';
    }

    return null; // Número válido
  }

  // === Validador de Teléfono ===

  /// Valida que el teléfono tenga un formato válido
  /// Acepta formatos: 0999999999, +593999999999, etc.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Expresión regular para validar teléfonos ecuatorianos
    final phoneRegex = RegExp(
      r'^(\+593|0)?[0-9]{9,10}$',
    );

    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Ingresa un teléfono válido';
    }

    return null; // Teléfono válido
  }

  // === Validador Personalizado ===

  /// Permite combinar múltiples validadores
  /// Ejemplo: Validators.combine([Validators.required, Validators.email])
  static String? Function(String?) combine(
      List<String? Function(String?)> validators,
      ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result; // Retorna el primer error encontrado
        }
      }
      return null; // Todos los validadores pasaron
    };
  }
}