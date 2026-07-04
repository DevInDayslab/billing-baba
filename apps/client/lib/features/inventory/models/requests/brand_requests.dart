class BrandListQuery {
  const BrandListQuery({
    this.page = 1,
    this.limit = 20,
    this.q,
    this.sort = 'name',
    this.order = 'asc',
  });

  final int page;
  final int limit;
  final String? q;
  final String sort;
  final String order;

  BrandListQuery copyWith({int? page, int? limit, String? q}) {
    return BrandListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      sort: sort,
      order: order,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'limit': limit,
    if (q != null && q!.isNotEmpty) 'q': q,
    'sort': sort,
    'order': order,
  };
}

class CreateBrandRequest {
  const CreateBrandRequest({required this.name});
  final String name;
  Map<String, dynamic> toJson() => {'name': name};
}

class UpdateBrandRequest {
  const UpdateBrandRequest({this.name});
  final String? name;
  Map<String, dynamic> toJson() => name != null ? {'name': name} : {};
}
