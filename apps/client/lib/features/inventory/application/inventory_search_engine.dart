import 'package:billing_baba/features/inventory/application/barcode_confidence.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:flutter/foundation.dart';

/// Metadata used to build a searchable index entry for one inventory item.
class InventorySearchableFields {
  const InventorySearchableFields({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.hsn,
    this.categoryName,
    this.unitName,
    this.brandName,
    this.aliases = const [],
  });

  factory InventorySearchableFields.fromInventoryItem(
    InventoryItem item, {
    String? categoryName,
    String? brandName,
    String? unitName,
    List<String> aliases = const [],
  }) {
    return InventorySearchableFields(
      id: item.id,
      name: item.name,
      sku: item.barcode,
      barcode: item.barcode,
      hsn: item.hsnCode,
      categoryName: categoryName,
      unitName: unitName ?? item.baseUnitShortName,
      brandName: brandName,
      aliases: aliases,
    );
  }

  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final String? hsn;
  final String? categoryName;
  final String? unitName;
  final String? brandName;
  final List<String> aliases;
}

/// Precomputed searchable representation of one item.
@immutable
class InventorySearchIndexEntry {
  const InventorySearchIndexEntry({
    required this.itemId,
    required this.displayName,
    required this.normalizedName,
    required this.normalizedBarcode,
    required this.searchableText,
    required this.nameTokens,
    required this.allTokens,
  });

  final String itemId;
  final String displayName;
  final String normalizedName;
  final String normalizedBarcode;
  final String searchableText;
  final Set<String> nameTokens;
  final Set<String> allTokens;
}

/// Character range in display text to highlight.
@immutable
class InventorySearchHighlightRange {
  const InventorySearchHighlightRange({required this.start, required this.end});

  final int start;
  final int end;
}

/// Token-based fuzzy search with precomputed indexes.
class InventorySearchEngine {
  factory InventorySearchEngine.build({
    required Iterable<InventorySearchableFields> items,
  }) {
    final entries = <String, InventorySearchIndexEntry>{};
    for (final item in items) {
      entries[item.id] = _buildEntry(item);
    }
    return InventorySearchEngine._(entries);
  }
  InventorySearchEngine._(this._entriesByItemId);

  final Map<String, InventorySearchIndexEntry> _entriesByItemId;

  static final _punctuationPattern = RegExp(r'[^\w\s]');
  static final _whitespacePattern = RegExp(r'\s+');
  static final _wordPattern = RegExp(r'\S+');
  static final _numericPattern = RegExp(r'\d+');
  static final _alphaPattern = RegExp('[a-z]+');
  static final _digitOnlyPattern = RegExp(r'^\d+$');

  bool get isEmpty => _entriesByItemId.isEmpty;

  bool matchesItemId(String itemId, String query) {
    final entry = _entriesByItemId[itemId];
    if (entry == null) return false;
    return _scoreEntry(entry, query) != null;
  }

  /// Returns item ids ranked best-first for [query].
  List<String> searchIds(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _entriesByItemId.keys.toList(growable: false);
    }

    final matches = <({String id, int score})>[];
    for (final entry in _entriesByItemId.values) {
      final score = _scoreEntry(entry, trimmed);
      if (score != null) {
        matches.add((id: entry.itemId, score: score));
      }
    }

    matches.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.id.compareTo(b.id);
    });

    return [for (final match in matches) match.id];
  }

  /// Filters and ranks [items] for [query], preserving engine ranking.
  List<InventoryItem> searchItems(
    Iterable<InventoryItem> items, {
    required String query,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return items.toList(growable: false);

    final rankedIds = searchIds(trimmed);
    final itemsById = {for (final item in items) item.id: item};
    return [
      for (final id in rankedIds)
        if (itemsById.containsKey(id)) itemsById[id]!,
    ];
  }

  /// Filters and ranks arbitrary records by [idSelector].
  List<T> searchRecords<T>({
    required Iterable<T> records,
    required String Function(T record) idSelector,
    required String query,
  }) {
    final trimmed = query.trim();
    final recordList = records.toList(growable: false);
    if (trimmed.isEmpty) return recordList;

    final rankedIds = searchIds(trimmed);
    final recordsById = {
      for (final record in recordList) idSelector(record): record,
    };
    return [
      for (final id in rankedIds)
        if (recordsById.containsKey(id)) recordsById[id]!,
    ];
  }

  static bool matchesFields(InventorySearchableFields fields, String query) {
    final engine = InventorySearchEngine.build(items: [fields]);
    return engine.searchIds(query).isNotEmpty;
  }

  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(_punctuationPattern, ' ')
        .replaceAll(_whitespacePattern, ' ')
        .trim();
  }

  static List<String> tokenize(String normalized) {
    if (normalized.isEmpty) return const [];

    final tokens = <String>{};
    for (final word in normalized.split(' ')) {
      if (word.isEmpty) continue;
      tokens.add(word);
      tokens.addAll(_splitAlphaNumeric(word));
    }

    return tokens.where(_isSearchableToken).toList(growable: false);
  }

  /// Query tokens are literal words only — sub-splits are index-side for matching.
  static List<String> tokenizeQuery(String normalized) {
    if (normalized.isEmpty) return const [];

    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }

  static List<InventorySearchHighlightRange> highlightRanges({
    required String text,
    required String query,
  }) {
    final queryTokens = tokenizeQuery(normalize(query));
    if (queryTokens.isEmpty) return const [];

    final ranges = <InventorySearchHighlightRange>[];
    for (final match in _wordPattern.allMatches(text)) {
      final word = text.substring(match.start, match.end);
      final normalizedWord = normalize(word);
      if (normalizedWord.isEmpty) continue;

      final wordTokens = tokenize(normalizedWord);
      final isMatch = queryTokens.any(
        (queryToken) => wordTokens.any(
          (wordToken) =>
              _tokenMatchType(queryToken, wordToken) != _TokenMatchType.none,
        ),
      );

      if (isMatch) {
        ranges.add(
          InventorySearchHighlightRange(start: match.start, end: match.end),
        );
      }
    }

    return ranges;
  }

  static InventorySearchIndexEntry _buildEntry(
    InventorySearchableFields fields,
  ) {
    final fieldValues = <String>[
      fields.name,
      ?fields.sku,
      ?fields.barcode,
      ?fields.hsn,
      ?fields.categoryName,
      ?fields.unitName,
      ?fields.brandName,
      ...fields.aliases,
    ];

    final normalizedName = normalize(fields.name);
    final normalizedBarcode = normalize(fields.barcode ?? '');
    final searchableText = normalize(fieldValues.join(' '));
    final nameTokens = tokenize(normalizedName).toSet();
    final allTokens = tokenize(searchableText).toSet();

    return InventorySearchIndexEntry(
      itemId: fields.id,
      displayName: fields.name,
      normalizedName: normalizedName,
      normalizedBarcode: normalizedBarcode,
      searchableText: searchableText,
      nameTokens: nameTokens,
      allTokens: allTokens,
    );
  }

  static Iterable<String> _splitAlphaNumeric(String token) {
    final parts = <String>{};
    for (final match in _numericPattern.allMatches(token)) {
      final value = match.group(0);
      if (value != null && value.isNotEmpty) {
        parts.add(value);
      }
    }
    for (final match in _alphaPattern.allMatches(token)) {
      final value = match.group(0);
      if (value != null && value.length > 1) {
        parts.add(value);
      }
    }
    return parts;
  }

  static bool _isSearchableToken(String token) => token.isNotEmpty;

  static int? _scoreEntry(InventorySearchIndexEntry entry, String rawQuery) {
    final normalizedQuery = normalize(rawQuery);
    if (normalizedQuery.isEmpty) return 0;

    if (BarcodeConfidence.isBarcodeLike(rawQuery)) {
      if (entry.normalizedBarcode.isNotEmpty &&
          entry.normalizedBarcode == normalizedQuery) {
        return 200000;
      }
      return null;
    }

    final queryTokens = tokenizeQuery(normalizedQuery);
    if (queryTokens.isEmpty) return null;

    var score = 0;

    if (entry.normalizedName == normalizedQuery) {
      score += 100000;
    } else if (entry.normalizedName.startsWith(normalizedQuery)) {
      score += 50000;
    }

    if (entry.normalizedBarcode.isNotEmpty &&
        entry.normalizedBarcode == normalizedQuery) {
      score += 200000;
    }

    var exactTokenMatches = 0;
    var partialTokenMatches = 0;
    final requireNameTokenMatch = queryTokens.length > 1;

    for (final queryToken in queryTokens) {
      final nameOnlyTokenMatch =
          requireNameTokenMatch || _requiresNameOnlyTokenMatch(queryToken);
      final matchType = nameOnlyTokenMatch
          ? _bestNameTokenMatch(queryToken, entry)
          : _bestTokenMatch(queryToken, entry);
      switch (matchType) {
        case _TokenMatchType.none:
          if (nameOnlyTokenMatch) {
            return null;
          }
          if (entry.searchableText.contains(queryToken)) {
            score += 10;
            partialTokenMatches++;
          } else {
            return null;
          }
        case _TokenMatchType.exactName:
          score += 1200;
          exactTokenMatches++;
        case _TokenMatchType.exactOther:
          score += 1000;
          exactTokenMatches++;
        case _TokenMatchType.partial:
          score += 100;
          partialTokenMatches++;
      }
    }

    score += exactTokenMatches * 50;
    score += partialTokenMatches * 25;

    return score;
  }

  static _TokenMatchType _bestNameTokenMatch(
    String queryToken,
    InventorySearchIndexEntry entry,
  ) {
    var best = _TokenMatchType.none;

    for (final nameToken in entry.nameTokens) {
      final match = _tokenMatchType(
        queryToken,
        nameToken,
        isNameToken: true,
      );
      if (match == _TokenMatchType.exactName) {
        return _TokenMatchType.exactName;
      }
      if (match == _TokenMatchType.partial) {
        best = _TokenMatchType.partial;
      }
    }

    return best;
  }

  static _TokenMatchType _bestTokenMatch(
    String queryToken,
    InventorySearchIndexEntry entry,
  ) {
    var best = _TokenMatchType.none;

    for (final nameToken in entry.nameTokens) {
      final match = _tokenMatchType(
        queryToken,
        nameToken,
        isNameToken: true,
      );
      if (match == _TokenMatchType.exactName) {
        return _TokenMatchType.exactName;
      }
      if (match == _TokenMatchType.partial) {
        best = _TokenMatchType.partial;
      }
    }

    for (final itemToken in entry.allTokens) {
      if (entry.nameTokens.contains(itemToken)) continue;
      final match = _tokenMatchType(queryToken, itemToken);
      if (match == _TokenMatchType.exactOther) {
        return _TokenMatchType.exactOther;
      }
      if (match == _TokenMatchType.partial) {
        best = _TokenMatchType.partial;
      }
    }

    return best;
  }

  static _TokenMatchType _tokenMatchType(
    String queryToken,
    String itemToken, {
    bool isNameToken = false,
  }) {
    if (queryToken == itemToken) {
      return isNameToken
          ? _TokenMatchType.exactName
          : _TokenMatchType.exactOther;
    }

    if (itemToken.contains(queryToken)) {
      if (_isWeakNumericSubstringMatch(queryToken, itemToken)) {
        return _TokenMatchType.none;
      }
      return _TokenMatchType.partial;
    }

    if (queryToken.length >= 3 && queryToken.contains(itemToken)) {
      return _TokenMatchType.partial;
    }

    return _TokenMatchType.none;
  }

  /// Short numeric queries (e.g. `3`, `12`) match item names only, not barcodes.
  static bool _requiresNameOnlyTokenMatch(String queryToken) {
    return _digitOnlyPattern.hasMatch(queryToken) && queryToken.length <= 2;
  }

  /// Ignores digit queries that only appear inside longer barcodes/SKUs.
  static bool _isWeakNumericSubstringMatch(
    String queryToken,
    String itemToken,
  ) {
    if (!_digitOnlyPattern.hasMatch(queryToken)) return false;
    if (!_digitOnlyPattern.hasMatch(itemToken)) return false;
    if (queryToken == itemToken) return false;
    return queryToken.length <= 2 && itemToken.length > queryToken.length;
  }
}

enum _TokenMatchType { none, partial, exactName, exactOther }
