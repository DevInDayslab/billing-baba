import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_sales_list_provider.g.dart';

@Riverpod(keepAlive: true)
class PosSalesList extends _$PosSalesList {
  @override
  List<PosSale> build() => const [];

  void addSale(PosSale sale) {
    state = [sale, ...state];
  }
}
