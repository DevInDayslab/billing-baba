import 'package:billing_baba/features/reports/models/reports_nav_intent.dart';
import 'package:billing_baba/features/search/domain/search_category.dart';
import 'package:flutter/material.dart';

/// One searchable page or command in the static registry.
final class SearchItem {
  const SearchItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    this.subtitle,
    this.keywords = const [],
    this.route,
    this.action,
    this.reportIntent,
    this.trackAsRecentPage = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final List<String> keywords;
  final IconData icon;
  final SearchCategory category;
  final String? route;
  final SearchActionKind? action;
  final ReportsNavIntent? reportIntent;

  /// Whether visiting this item should update recent pages storage.
  final bool trackAsRecentPage;

  bool get isPage => category == SearchCategory.page;
  bool get isCommand => category == SearchCategory.command;
}

/// A grouped section of search results for display.
final class SearchResultSection {
  const SearchResultSection({
    required this.kind,
    required this.items,
  });

  final SearchSectionKind kind;
  final List<SearchItem> items;
}
