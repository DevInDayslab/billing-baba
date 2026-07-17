import 'package:billing_baba/shared/widgets/table_filters/filter_types.dart';
import 'package:flutter/material.dart';

/// Optional hook for future custom filter widgets without changing existing code.
typedef CustomFilterWidgetBuilder =
    Widget Function({
      required ColumnFilter config,
      required Object? initialValue,
      required void Function(Object? value) onApply,
    });

/// Describes a single table column filter — pages only supply config; the popup
/// renders itself from [type] and optional [values].
class ColumnFilter {
  const ColumnFilter({
    required this.id,
    required this.title,
    required this.type,
    this.values = const [],
    this.hintText,
    this.rangeLabel,
    this.maxValue,
    this.prefixText,
    this.searchable = true,
    this.disabled = false,
    this.exclusivePairs = const [],
    this.customBuilder,
  });

  final String id;
  final String title;
  final FilterType type;
  final List<String> values;
  final String? hintText;
  final String? rangeLabel;
  final double? maxValue;
  final String? prefixText;
  final bool searchable;
  final bool disabled;

  /// Mutually exclusive option pairs for [FilterType.multiSelect].
  final List<(String, String)> exclusivePairs;
  final CustomFilterWidgetBuilder? customBuilder;
}

// ---------------------------------------------------------------------------
// Operators — Vyapar canonical set only
// ---------------------------------------------------------------------------

enum TextColumnOperator {
  contains('Contains'),
  equalTo('Exact Match');

  const TextColumnOperator(this.label);
  final String label;
}

enum NumberColumnOperator {
  equalTo('Equal To'),
  lessThan('Less Than'),
  greaterThan('Greater Than');

  const NumberColumnOperator(this.label);
  final String label;
}

enum DateColumnOperator {
  equalTo('Equal To'),
  lessThan('Less Than'),
  greaterThan('Greater Than'),
  range('Range');

  const DateColumnOperator(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// Filter value types
// ---------------------------------------------------------------------------

class TextColumnFilter {
  const TextColumnFilter({
    required this.operator,
    required this.value,
  });

  final TextColumnOperator operator;
  final String value;

  bool get isActive => value.trim().isNotEmpty;

  bool matches(String fieldValue) {
    final query = value.trim();
    if (query.isEmpty) return true;

    final target = fieldValue.trim().toLowerCase();
    final needle = query.toLowerCase();

    return switch (operator) {
      TextColumnOperator.equalTo => target == needle,
      TextColumnOperator.contains => target.contains(needle),
    };
  }
}

class NumberColumnFilter {
  const NumberColumnFilter({
    required this.operator,
    required this.value,
  });

  final NumberColumnOperator operator;
  final double value;

  bool get isActive => true;

  bool matches(double fieldValue) {
    return switch (operator) {
      NumberColumnOperator.equalTo => fieldValue == value,
      NumberColumnOperator.lessThan => fieldValue < value,
      NumberColumnOperator.greaterThan => fieldValue > value,
    };
  }
}

/// Backwards-compatible alias used by Sales / Inventory providers for numeric
/// column filters (amount, quantity, price, balance, etc.).
typedef AmountColumnFilter = NumberColumnFilter;

class DateColumnFilter {
  const DateColumnFilter({
    required this.operator,
    this.date,
    this.startDate,
    this.endDate,
  });

  final DateColumnOperator operator;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isActive => operator == DateColumnOperator.range
      ? startDate != null && endDate != null
      : date != null;

  bool matches(DateTime value) {
    final target = DateTime(value.year, value.month, value.day);

    if (operator == DateColumnOperator.range) {
      if (startDate == null || endDate == null) return true;
      final start = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
      );
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return !target.isBefore(start) && !target.isAfter(end);
    }

    if (date == null) return true;
    final filterDate = DateTime(date!.year, date!.month, date!.day);

    return switch (operator) {
      DateColumnOperator.equalTo => target == filterDate,
      DateColumnOperator.lessThan => target.isBefore(filterDate),
      DateColumnOperator.greaterThan => target.isAfter(filterDate),
      DateColumnOperator.range => true,
    };
  }
}

class SelectColumnFilter {
  const SelectColumnFilter({required this.value});

  final String? value;

  bool get isActive => value != null && value!.trim().isNotEmpty;

  bool matches(String fieldValue) {
    final selected = value?.trim();
    if (selected == null || selected.isEmpty) return true;
    return fieldValue.trim().toLowerCase() == selected.toLowerCase();
  }
}

class MultiSelectColumnFilter {
  const MultiSelectColumnFilter({required this.values});

  final Set<String> values;

  bool get isActive => values.isNotEmpty;

  bool matches(String fieldValue) {
    if (values.isEmpty) return true;
    final normalized = fieldValue.trim().toLowerCase();
    return values.any((v) => v.trim().toLowerCase() == normalized);
  }

  bool matchesAny(Iterable<String> fieldValues) {
    if (values.isEmpty) return true;
    return fieldValues.any(matches);
  }
}

/// [value] null means "All" — no filter applied.
class BooleanColumnFilter {
  const BooleanColumnFilter({this.value});

  final bool? value;

  bool get isActive => value != null;

  bool matches(bool fieldValue) {
    if (value == null) return true;
    return fieldValue == value;
  }
}

/// Continuous range filter — loyalty points, ratings, percentages, etc.
/// Not for currency amounts.
class RangeSliderColumnFilter {
  const RangeSliderColumnFilter({
    required this.min,
    required this.max,
    this.ceiling = defaultCeiling,
  });

  static const defaultCeiling = 100.0;

  final double min;
  final double max;
  final double ceiling;

  bool get isActive => min > 0 || max < ceiling;

  bool matches(double amount) {
    if (amount < min) return false;
    if (max >= ceiling) return true;
    return amount <= max;
  }
}

/// Metadata for the developer playground reference table.
class FilterWidgetSpec {
  const FilterWidgetSpec({
    required this.name,
    required this.widgetClass,
    required this.typeLabel,
    required this.operators,
    required this.usedIn,
    required this.exampleFields,
    required this.config,
  });

  final String name;
  final String widgetClass;
  final String typeLabel;
  final List<String> operators;
  final List<String> usedIn;
  final List<String> exampleFields;
  final ColumnFilter config;
}
