/// ─────────────────────────────────────────────────────────────────────
/// Pulse RBAC — Barrel Export
/// ─────────────────────────────────────────────────────────────────────
/// Import this single file to access the entire RBAC system:
///
///   import '/rbac/rbac.dart';
///
/// This gives you access to:
///   - Permission (enum of all permissions)
///   - AppRole (enum of all roles)
///   - NavItem (enum of all navigation items)
///   - AccessControl (main API for permission checks)
///   - rolePermissions (the permission matrix)
///   - roleNavItems (the navigation visibility matrix)
/// ─────────────────────────────────────────────────────────────────────
library;

export 'permissions.dart';
export 'roles.dart';
export 'role_config.dart';
export 'access_control.dart';
