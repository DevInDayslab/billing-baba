import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'parties_provider.g.dart';

@riverpod
class Parties extends _$Parties {
  @override
  List<String> build() => List<String>.from(SaleDropdownOptions.parties);

  void addParty(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.contains(trimmed)) return;
    state = [...state, trimmed];
  }
}
