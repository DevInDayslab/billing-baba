enum PermissionAction {
  view,
  create,
  edit,
  share,
  delete,
}

extension PermissionActionX on PermissionAction {
  String get displayLabel => switch (this) {
    PermissionAction.view => 'View',
    PermissionAction.create => 'Create',
    PermissionAction.edit => 'Edit',
    PermissionAction.share => 'Share',
    PermissionAction.delete => 'Delete',
  };
}
