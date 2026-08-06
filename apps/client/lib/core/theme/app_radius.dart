import 'package:flutter/material.dart';

/// Border radius design tokens.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double button = 16;
  static const double search = 18;
  static const double card = 20;
  static const double bottomSheet = 24;
  static const double dialog = 24;
  static const double fab = 28;

  /// Legacy alias — maps to [button].
  static const double lg = button;

  static BorderRadius get smBorder => BorderRadius.circular(sm);
  static BorderRadius get mdBorder => BorderRadius.circular(md);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static BorderRadius get searchBorder => BorderRadius.circular(search);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get bottomSheetBorder =>
      const BorderRadius.vertical(top: Radius.circular(bottomSheet));
  static BorderRadius get dialogBorder => BorderRadius.circular(dialog);
  static BorderRadius get fabBorder => BorderRadius.circular(fab);

  /// Legacy alias.
  static BorderRadius get lgBorder => buttonBorder;
}
