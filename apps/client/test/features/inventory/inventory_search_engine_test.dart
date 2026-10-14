import 'package:billing_baba/features/inventory/application/inventory_search_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleItem = InventorySearchableFields(
    id: 'item-1',
    name: 'Amul Taaza Milk 500ml',
    sku: 'DAI-500',
    barcode: '8901234567890',
    hsn: '0401',
    categoryName: 'Dairy',
    unitName: 'Pieces',
    brandName: 'Amul',
  );

  late InventorySearchEngine engine;

  setUp(() {
    engine = InventorySearchEngine.build(items: [sampleItem]);
  });

  group('normalize', () {
    test('lowercases, trims, collapses spaces, and strips punctuation', () {
      expect(
        InventorySearchEngine.normalize('  Amul   Taaza!!  Milk '),
        'amul taaza milk',
      );
    });
  });

  group('tokenize', () {
    test('splits words and numeric parts from mixed tokens', () {
      expect(
        InventorySearchEngine.tokenize('amul taaza milk 500ml'),
        containsAll(['amul', 'taaza', 'milk', '500ml', '500']),
      );
    });
  });

  group('search', () {
    const queries = [
      'amul',
      'milk',
      'taaza',
      '500',
      '500ml',
      'amul milk',
      'milk amul',
      'taaza milk',
      'milk taaza',
      'amul taaza',
      'taaza amul',
      'amul 500',
      '500 amul',
      'milk 500',
      '500 milk',
      'amul taaza milk',
      'milk amul taaza',
      'amul milk 500',
      '500 taaza milk',
      'taaza amul 500ml',
    ];

    for (final query in queries) {
      test('matches "$query"', () {
        expect(engine.searchIds(query), [sampleItem.id]);
      });
    }

    test('ranks exact name above partial token matches', () {
      final rankedEngine = InventorySearchEngine.build(
        items: const [
          sampleItem,
          InventorySearchableFields(
            id: 'item-2',
            name: 'Milk Powder',
          ),
          InventorySearchableFields(
            id: 'item-3',
            name: 'Amul Taaza Milk 500ml',
          ),
        ],
      );

      final ids = rankedEngine.searchIds('Amul Taaza Milk 500ml');
      expect(ids.first, sampleItem.id);
    });

    test('query tokens stay literal words without sub-splitting', () {
      expect(
        InventorySearchEngine.tokenizeQuery('taaza amul 500ml'),
        ['taaza', 'amul', '500ml'],
      );
    });

    test('matches barcode exactly', () {
      expect(engine.searchIds('8901234567890'), [sampleItem.id]);
    });

    test('does not fuzzy-match barcode-like queries to unrelated items', () {
      final rankedEngine = InventorySearchEngine.build(
        items: const [
          sampleItem,
          InventorySearchableFields(
            id: 'item-2',
            name: 'Maggi 2-Min Noodles',
            hsn: '1902',
          ),
        ],
      );

      expect(rankedEngine.searchIds('1234567890123'), isEmpty);
    });

    test('matches category and brand fields', () {
      expect(engine.searchIds('dairy'), [sampleItem.id]);
      expect(engine.searchIds('amul butter'), isEmpty);
      expect(engine.searchIds('amul'), [sampleItem.id]);
    });

    test('multi-word queries require every token to match the item name', () {
      final rankedEngine = InventorySearchEngine.build(
        items: const [
          InventorySearchableFields(
            id: 'test-1',
            name: 'Test 1',
            barcode: '1790938395123',
          ),
          InventorySearchableFields(
            id: 'test-2',
            name: 'Test 2',
            barcode: '1790938433123',
          ),
        ],
      );

      expect(rankedEngine.searchIds('test 1'), ['test-1']);
      expect(rankedEngine.searchIds('test 2'), ['test-2']);
      expect(rankedEngine.searchIds('test'), containsAll(['test-1', 'test-2']));
    });

    test('short numeric queries match item names, not barcode digits', () {
      final rankedEngine = InventorySearchEngine.build(
        items: const [
          InventorySearchableFields(
            id: 'test-1',
            name: 'Test 1',
            barcode: '1790938395123',
          ),
          InventorySearchableFields(
            id: 'test-2',
            name: 'Test 2',
            barcode: '1790938433123',
          ),
          InventorySearchableFields(
            id: 'test-3',
            name: 'Test 3',
            barcode: '4354bcc5-1000',
          ),
        ],
      );

      expect(rankedEngine.searchIds('3'), ['test-3']);
      expect(rankedEngine.searchIds('1'), ['test-1']);
      expect(rankedEngine.searchIds('2'), ['test-2']);
    });
  });

  group('highlightRanges', () {
    test('highlights each matched token independently', () {
      final ranges = InventorySearchEngine.highlightRanges(
        text: 'Amul Taaza Milk 500ml',
        query: 'milk taaza',
      );

      expect(ranges.length, 2);
      expect(
        'Amul Taaza Milk 500ml'.substring(ranges[0].start, ranges[0].end),
        'Taaza',
      );
      expect(
        'Amul Taaza Milk 500ml'.substring(ranges[1].start, ranges[1].end),
        'Milk',
      );
    });

    test('highlights numeric token inside mixed word', () {
      final ranges = InventorySearchEngine.highlightRanges(
        text: 'Amul Taaza Milk 500ml',
        query: '500',
      );

      expect(ranges.length, 1);
      expect(
        'Amul Taaza Milk 500ml'.substring(ranges[0].start, ranges[0].end),
        '500ml',
      );
    });
  });
}
