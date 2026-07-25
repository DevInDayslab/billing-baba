import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges shell-level keyboard shortcuts to the search dialog.
class SearchDialogController {
  void Function(BuildContext context)? _open;

  void register({required void Function(BuildContext context) open}) {
    _open = open;
  }

  void unregister() {
    _open = null;
  }

  void open(BuildContext context) => _open?.call(context);
}

final searchDialogProvider =
    NotifierProvider<SearchDialogNotifier, SearchDialogController>(
      SearchDialogNotifier.new,
    );

class SearchDialogNotifier extends Notifier<SearchDialogController> {
  @override
  SearchDialogController build() => SearchDialogController();

  void register({required void Function(BuildContext context) open}) {
    state.register(open: open);
  }

  void unregister() => state.unregister();

  void open(BuildContext context) => state.open(context);
}
