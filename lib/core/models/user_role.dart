// #region Autenticacion | Funcionalidad | Modelo de rol de usuario
enum UserRole {
  tecnico,
  admin,
  cliente;

  String get label {
    switch (this) {
      case UserRole.tecnico:
        return 'Tecnico';
      case UserRole.admin:
        return 'Admin';
      case UserRole.cliente:
        return 'Cliente';
    }
  }

  String get headline {
    switch (this) {
      case UserRole.tecnico:
        return 'Panel tecnico';
      case UserRole.admin:
        return 'Panel administrativo';
      case UserRole.cliente:
        return 'Area de cliente';
    }
  }
}
// #endregion
