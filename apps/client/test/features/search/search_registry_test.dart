import 'package:billing_baba/features/search/application/search_matcher.dart';
import 'package:billing_baba/features/search/application/search_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry is populated at library load with ERP pages only', () {
    expect(SearchRegistry.pages, isNotEmpty);
    expect(SearchRegistry.commands, isNotEmpty);
    expect(SearchRegistry.allItems.length, greaterThan(40));

    final titles = SearchRegistry.pages.map((item) => item.title).toList();
    expect(titles, isNot(contains('Developer')));
    expect(titles, isNot(contains('Components')));
    expect(titles, isNot(contains('Typography')));
  });

  test('searching sale returns key sale pages and commands', () {
    final pageMatches = SearchMatcher.filter(
      items: SearchRegistry.pages,
      query: 'sale',
    );
    final commandMatches = SearchMatcher.filter(
      items: SearchRegistry.commands,
      query: 'sale',
    );

    final pageTitles = pageMatches.map((item) => item.title).toSet();
    final commandTitles = commandMatches.map((item) => item.title).toSet();

    expect(pageTitles, contains('Sales'));
    expect(pageTitles, contains('Sale Invoices'));
    expect(pageTitles, contains('Sale Report'));
    expect(pageTitles, contains('Sale Return'));
    expect(commandTitles, contains('Add Sale'));
    expect(commandTitles, contains('Add Sale FA'));
  });

  test('separator variants match sale return page title', () {
    final matches = SearchMatcher.filter(
      items: SearchRegistry.pages,
      query: 'sale return',
    );

    expect(
      matches.map((item) => item.title),
      contains('Sale Return'),
    );

    final hyphenMatches = SearchMatcher.filter(
      items: SearchRegistry.pages,
      query: 'sale-return',
    );
    expect(
      hyphenMatches.map((item) => item.title),
      contains('Sale Return'),
    );
  });

  test('exact and prefix matches rank before contains matches', () {
    final matches = SearchMatcher.filter(
      items: SearchRegistry.pages,
      query: 'dash',
    );

    expect(matches, isNotEmpty);
    expect(matches.first.title, 'Dashboard');
  });

  test(
    'gst backup barcode party payment stock report settings queries match',
    () {
      for (final query in [
        'gst',
        'backup',
        'barcode',
        'party',
        'payment',
        'stock',
        'report',
        'settings',
      ]) {
        final pages = SearchMatcher.filter(
          items: SearchRegistry.pages,
          query: query,
        );
        final commands = SearchMatcher.filter(
          items: SearchRegistry.commands,
          query: query,
        );
        expect(
          pages.isNotEmpty || commands.isNotEmpty,
          isTrue,
          reason: 'Expected matches for $query',
        );
      }
    },
  );

  test('nonsense query returns no matches', () {
    final pages = SearchMatcher.filter(
      items: SearchRegistry.pages,
      query: 'kale',
    );
    final commands = SearchMatcher.filter(
      items: SearchRegistry.commands,
      query: 'asdfgh',
    );

    expect(pages, isEmpty);
    expect(commands, isEmpty);
  });
}
