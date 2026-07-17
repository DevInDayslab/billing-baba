import 'dart:io' show Platform;

import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_repository.dart';
import 'package:billing_baba/features/collaboration/data/fake_collaboration_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collaboration_repository_provider.g.dart';

String _defaultDeviceName() {
  if (kIsWeb) return 'Web Browser';
  if (Platform.isMacOS) return 'MacBook Pro';
  if (Platform.isWindows) return 'Windows Desktop';
  if (Platform.isAndroid) return 'Android Device';
  if (Platform.isIOS) return 'iPhone';
  return 'Desktop';
}

@Riverpod(keepAlive: true)
CollaborationRepository collaborationRepository(Ref ref) {
  final auth = ref.watch(authProvider);
  final user = auth.session?.user;
  final business = auth.session?.businesses.isNotEmpty == true
      ? auth.session!.businesses.first
      : null;

  final currentPhone = user?.phone ?? '+91 7987016325';

  return FakeCollaborationRepository(
    businessName: business?.name ?? 'Sharma Traders',
    sessionContext: CollaborationSessionContext(
      currentUserPhone: currentPhone,
      ownerPhone: currentPhone,
      currentDeviceName: _defaultDeviceName(),
    ),
  );
}

@Riverpod(keepAlive: true)
CollaborationService collaborationService(Ref ref) {
  final repository = ref.watch(collaborationRepositoryProvider);
  return CollaborationService(repository);
}
