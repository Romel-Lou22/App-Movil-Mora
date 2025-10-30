import 'package:equatable/equatable.dart';

/// Entidad de Usuario (Domain Layer)
/// Representa al usuario en la lógica de negocio
/// NO depende de ningún framework o librería externa (excepto Equatable)
class User extends Equatable {
  /// ID único del usuario en Supabase
  final String id;

  /// Email del usuario
  final String email;

  /// Nombre completo del usuario (opcional)
  final String? fullName;

  /// URL de la foto de perfil (opcional)
  final String? avatarUrl;

  /// Número de teléfono (opcional)
  final String? phone;

  /// Fecha de creación de la cuenta
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  /// Si el email está verificado
  final bool emailVerified;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
  });

  /// Usuario vacío (para estados iniciales)
  static const empty = User(
    id: '',
    email: '',
    createdAt: null,
    emailVerified: false,
  );

  /// Verifica si el usuario está vacío
  bool get isEmpty => this == User.empty;

  /// Verifica si el usuario NO está vacío
  bool get isNotEmpty => this != User.empty;

  /// Obtiene las iniciales del nombre (para avatares)
  String get initials {
    if (fullName == null || fullName!.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }

    final names = fullName!.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  /// Obtiene el nombre a mostrar (fullName o email)
  String get displayName => fullName ?? email;

  /// Copia el usuario con algunos campos modificados
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    avatarUrl,
    phone,
    createdAt,
    updatedAt,
    emailVerified,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, emailVerified: $emailVerified)';
  }
}