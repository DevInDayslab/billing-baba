class GodownListQuery {
  const GodownListQuery({
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

  GodownListQuery copyWith({int? page, int? limit, String? q}) {
    return GodownListQuery(
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

class CreateGodownRequest {
  const CreateGodownRequest({required this.name, this.address});
  final String name;
  final String? address;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (address != null && address!.isNotEmpty) 'address': address,
  };
}

class UpdateGodownRequest {
  const UpdateGodownRequest({this.name, this.address});
  final String? name;
  final String? address;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    return json;
  }
}
