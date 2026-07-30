/// Permission outcome for a single cell in the role matrix.
enum PermissionLevel {
  allowed,
  denied,
  notApplicable,
}

extension PermissionLevelX on PermissionLevel {
  bool get isAllowed => this == PermissionLevel.allowed;
  bool get isDenied => this == PermissionLevel.denied;
  bool get isNotApplicable => this == PermissionLevel.notApplicable;
}
