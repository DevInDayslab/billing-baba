import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sale_screen_minimized_provider.g.dart';

/// True after the user minimizes POS; cleared when the sale screen is closed.
@Riverpod(keepAlive: true)
class SaleScreenMinimized extends _$SaleScreenMinimized {
  @override
  bool build() => false;

  void markMinimized() => state = true;

  void clear() => state = false;
}
