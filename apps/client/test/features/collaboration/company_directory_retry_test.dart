import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('companyDirectoryProvider disables Riverpod auto-retry', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/api/v1/businesses'),
      type: DioExceptionType.connectionError,
    );

    expect(companyDirectoryProvider.retry, isNotNull);
    expect(companyDirectoryProvider.retry!(0, error), isNull);
    expect(companyDirectoryProvider.retry!(3, error), isNull);

    expect(companyDirectoryServiceProvider.retry, isNotNull);
    expect(companyDirectoryServiceProvider.retry!(0, error), isNull);
  });
}
