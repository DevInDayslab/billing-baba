import 'package:billing_baba/shared/widgets/table_filters/filter_models.dart'
    show ColumnFilter;
import 'package:billing_baba/shared/widgets/table_filters/table_filters.dart'
    show ColumnFilter;

/// Supported column filter input types for [ColumnFilter] configuration.
enum FilterType {
  text,
  number,
  date,
  singleSelect,
  multiSelect,
  boolean,
  rangeSlider,
}
