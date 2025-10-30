import '../../domain/entities/user.dart';

/// Modelo de Usuario (Data Layer)
/// Extiende la entidad User y agrega métodos de serialización
/// Convierte entre JSON (Supabase) y la entidad User (Domain)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.createdAt,
    super.fullName,
    super.avatarUrl,
    super.phone,
    super.updatedAt,
    super.emailVerified,
  });

  /// Crea un UserModel desde un JSON (respuesta de Supabase)
  ///
  /// Ejemplo de JSON de Supabase Auth:
  /// ```json
  /// {
  ///   "id": "uuid-123",
  ///   "email": "user@example.com",
  ///   "user_metadata": {
  ///     "full_name": "Juan Pérez",
  ///     "avatar_url": "https://...",
  ///     "phone": "0999999999"
  ///   },
  ///   "email_confirmed_at": "2024-01-01T00:00:00Z",
  ///   "created_at": "2024-01-01T00:00:00Z",
  ///   "updated_at": "2024-01-01T00:00:00Z"
  /// }
  /// ```
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // user_metadata puede venir como null
    final metadata = json['user_metadata'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: metadata['full_name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      phone: metadata['phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      emailVerified: json['email_confirmed_at'] != null,
    );
  }

  /// Convierte el UserModel a JSON para enviar a Supabase
  /// Útil para actualizar el perfil del usuario
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_metadata': {
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'phone': phone,
      },
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea un UserModel desde la entidad User (Domain)
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatarUrl: user.avatarUrl,
      phone: user.phone,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      emailVerified: user.emailVerified,
    );
  }

  /// Convierte el UserModel a la entidad User (Domain)
  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      emailVerified: emailVerified,
    );
  }

  /// Copia el UserModel con algunos campos modificados
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
  }) {
    return UserModel(
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
}