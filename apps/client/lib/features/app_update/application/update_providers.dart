import 'package:billing_baba/features/app_update/data/update_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});
