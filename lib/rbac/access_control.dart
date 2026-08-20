/// ─────────────────────────────────────────────────────────────────────
/// Pulse RBAC — Access Control Helper
/// ─────────────────────────────────────────────────────────────────────
/// The primary API for checking permissions throughout the app.
///
/// Usage:
///   // Check a single permission
///   if (AccessControl.hasPermission(context, Permission.posCreateSale)) {
///     // show POS create button
///   }
///
///   // Check multiple permissions (any match)
///   if (AccessControl.hasAnyPermission(context, [
///     Permission.posCreateSale,
///     Permission.posEditSale,
///   ])) { ... }
///
///   // Check navigation visibility
///   if (AccessControl.canSeeNavItem(context, NavItem.humanResource)) {
///     // show sidebar item
///   }
///
///   // Get the current user's role
///   final role = AccessControl.currentRole(context);
///   if (role.isOwnerLevel) { ... }
///
///   // Route guard — redirect if no permission
///   if (!AccessControl.hasPermission(context, Permission.hrView)) {
///     context.goNamed(HomeWidget.routeName);
///   }
/// ─────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'permissions.dart';
import 'roles.dart';
import 'role_config.dart';

class AccessControl {
  // ─── Debug Role Override (testing only) ─────────────────────────

  /// When non-null, overrides the real Firestore role for testing.
  /// Only active in debug mode. Reset with [clearDebugRole].
  static AppRole? _debugOverrideRole;

  /// Temporarily override the current user's role for testing.
  /// Only works in debug/profile mode (ignored in release builds).
  static void setDebugRole(AppRole role) {
    assert(() {
      _debugOverrideRole = role;
      return true;
    }());
  }

  /// Clear the debug role override and revert to the real Firestore role.
  static void clearDebugRole() {
    _debugOverrideRole = null;
  }

  /// Whether a debug role override is active.
  static bool get hasDebugOverride => _debugOverrideRole != null;

  /// The currently active debug override, if any.
  static AppRole? get debugOverrideRole => _debugOverrideRole;

  // ─── Role Resolution ─────────────────────────────────────────────

  /// Resolve the current user's AppRole from the Firestore user document.
  /// Combines both `accountType` and `role` fields to determine the
  /// canonical AppRole.
  ///
  /// Logic:
  ///   1. If accountType is 'Pulse' → duniyaAdmin or duniyaStaff
  ///   2. If accountType is 'Pharmacy' → use the `role` field
  ///   3. Fallback → unknown
  static AppRole currentRole(BuildContext context) {
    // Use debug override if set (testing only)
    if (_debugOverrideRole != null) return _debugOverrideRole!;

    final userDoc = currentUserDocument;
    if (userDoc == null) return AppRole.unknown;

    final accountType = userDoc.accountType ?? '';
    final role = userDoc.role ?? '';

    // Pulse network users — resolve duniyaAdmin vs duniyaStaff from the
    // Firestore `role` field.  Only explicit admin/owner values map to
    // duniyaAdmin; everything else (including empty/missing) maps to
    // duniyaStaff for least-privilege safety.
    if (AppRole.isDuniyaAccountType(accountType)) {
      final normalizedRole = role.toLowerCase().replaceAll(' ', '_');
      if (normalizedRole == 'admin' ||
          normalizedRole == 'owner' ||
          normalizedRole == 'duniya_admin' ||
          normalizedRole == 'duniyaadmin') {
        return AppRole.duniyaAdmin;
      }
      return AppRole.duniyaStaff; // Least-privilege default for Duniya users
    }

    // Pharmacy users — map from the role field
    return AppRole.fromFirestoreValue(role);
  }

  /// Whether the current user is a Pulse network user.
  static bool isDuniyaUser(BuildContext context) {
    return currentRole(context).isDuniyaRole;
  }

  /// Whether the current user is a pharmacy-side user.
  static bool isPharmacyUser(BuildContext context) {
    return currentRole(context).isPharmacyRole;
  }

  /// Whether the current user is an Owner (pharmacy owner).
  static bool isOwner(BuildContext context) {
    return currentRole(context).isOwnerLevel;
  }

  // ─── Permission Checks ───────────────────────────────────────────

  /// Check if the current user has a specific permission.
  static bool hasPermission(BuildContext context, Permission permission) {
    final role = currentRole(context);
    final permissions = rolePermissions[role] ?? {};
    return permissions.contains(permission);
  }

  /// Check if the current user has ALL of the specified permissions.
  static bool hasAllPermissions(
    BuildContext context,
    List<Permission> permissions,
  ) {
    return permissions.every((p) => hasPermission(context, p));
  }

  /// Check if the current user has ANY of the specified permissions.
  static bool hasAnyPermission(
    BuildContext context,
    List<Permission> permissions,
  ) {
    return permissions.any((p) => hasPermission(context, p));
  }

  // ─── Navigation Visibility ───────────────────────────────────────

  /// Check if the current user can see a specific navigation item.
  static bool canSeeNavItem(BuildContext context, NavItem item) {
    final role = currentRole(context);
    final items = roleNavItems[role] ?? {};
    return items.contains(item);
  }

  // ─── Convenience: Permission Sets ────────────────────────────────

  /// Get all permissions for the current user's role.
  static Set<Permission> currentPermissions(BuildContext context) {
    final role = currentRole(context);
    return rolePermissions[role] ?? {};
  }

  /// Get all nav items visible to the current user's role.
  static Set<NavItem> currentNavItems(BuildContext context) {
    final role = currentRole(context);
    return roleNavItems[role] ?? {};
  }

  // ─── Firestore Parent Reference Helper ───────────────────────────

  /// Returns the appropriate Firestore parent reference based on the
  /// user's role. Owners use their own reference; staff use ownerRef.
  ///
  /// This replaces the scattered `role == 'Owner'` checks throughout
  /// the codebase that determine query parent references.
  static DocumentReference? parentRef(BuildContext context) {
    final userDoc = currentUserDocument;
    if (userDoc == null) return null;

    if (isOwner(context)) {
      return currentUserReference;
    }
    return userDoc.ownerRef;
  }

  /// Context-free variant of [parentRef] for use in places where
  /// BuildContext is not available (e.g., top-level functions,
  /// background services, main.dart init).
  ///
  /// Accepts the user document and reference directly instead of
  /// reading from the widget tree.
  static DocumentReference? parentRefFromDoc(
    UserRecord? userDoc,
    DocumentReference? userRef,
  ) {
    if (userDoc == null || userRef == null) return null;

    final role = AppRole.fromFirestoreValue(userDoc.role);
    if (role.isOwnerLevel) {
      return userRef;
    }
    return userDoc.ownerRef;
  }

  // ─── Role Display ────────────────────────────────────────────────

  /// Get the human-readable display name for the current user's role.
  static String currentRoleDisplayName(BuildContext context) {
    return currentRole(context).displayName;
  }

  // ─── Backward Compatibility ──────────────────────────────────────

  /// Backward-compatible check for the old `role == 'Owner'` pattern.
  /// Returns true if the user is an Owner-level pharmacy user.
  ///
  /// Prefer using `hasPermission()` or `isOwner()` for new code.
  /// This exists to ease migration from the old inline checks.
  static bool isOwnerLegacy(BuildContext context) {
    return isOwner(context);
  }

  /// Backward-compatible check for the old `_isDuniyaUser` pattern.
  /// Returns true if the user is a Pulse network user.
  ///
  /// Prefer using `isDuniyaUser()` for new code.
  static bool isDuniyaLegacy(BuildContext context) {
    return isDuniyaUser(context);
  }
}
