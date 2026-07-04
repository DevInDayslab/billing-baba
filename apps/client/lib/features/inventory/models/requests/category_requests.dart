class CategoryListQuery {
  const CategoryListQuery({
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

  CategoryListQuery copyWith({
    int? page,
    int? limit,
    String? q,
    String? sort,
    String? order,
  }) {
    return CategoryListQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      q: q ?? this.q,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (q != null && q!.isNotEmpty) 'q': q,
      'sort': sort,
      'order': order,
    };
  }
}

class CreateCategoryRequest {
  const CreateCategoryRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}

class UpdateCategoryRequest {
  const UpdateCategoryRequest({this.name});

  final String? name;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    return json;
  }
}
