import 'package:billing_baba/features/parties/models/party_list_filter.dart';

/// Maps UI list state to backend query parameters.
class PartyListQuery {
  const PartyListQuery({
    this.page = 1,
    this.limit = 100,
    this.q,
    this.partyType,
    this.isActive,
    this.sort = 'name',
    this.order = 'asc',
  });

  final int page;
  final int limit;
  final String? q;
  final String? partyType;
  final bool? isActive;
  final String sort;
  final String order;

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (q != null && q!.isNotEmpty) 'q': q,
    if (partyType != null) 'party_type': partyType,
    if (isActive != null) 'is_active': isActive! ? 'true' : 'false',
    'sort': sort,
    'order': order,
  };

  static PartyListQuery fromFilter({
    String? search,
    PartyListFilter filter = PartyListFilter.all,
    int page = 1,
  }) {
    final isActive = switch (filter) {
      PartyListFilter.active => true,
      PartyListFilter.inactive => false,
      _ => null,
    };

    return PartyListQuery(
      page: page,
      q: search,
      isActive: isActive,
      sort: 'opening_balance',
      order: 'desc',
    );
  }
}
