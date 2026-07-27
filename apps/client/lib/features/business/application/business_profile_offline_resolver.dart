import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/auth/models/business_summary.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves a business profile from local/session data when the API is unreachable.
Future<BusinessProfileModel?> resolveOfflineBusinessProfile({
  required Ref ref,
  required BusinessService service,
  String? businessId,
}) async {
  final cached = await service.readCachedBusinessProfile();
  if (cached != null && _matchesBusiness(cached.id, businessId)) {
    return cached;
  }

  final session = ref.read(companySessionProvider);
  if (session != null && _matchesBusiness(session.companyId, businessId)) {
    return _profileFromCompanySession(session);
  }

  final directory = ref.read(companyDirectoryProvider).asData?.value;
  final directoryProfile = _profileFromDirectory(directory, businessId);
  if (directoryProfile != null) {
    return directoryProfile;
  }

  final authBusinesses = ref.read(authProvider).session?.businesses ?? const [];
  final authProfile = _profileFromAuthBusinesses(authBusinesses, businessId);
  if (authProfile != null) {
    return authProfile;
  }

  try {
    final cachedBusinesses = await service.readCachedBusinesses();
    final cachedListProfile = _profileFromBusinessList(
      cachedBusinesses,
      businessId,
    );
    if (cachedListProfile != null) {
      return cachedListProfile;
    }
  } on Object {
    // Ignore cache read issues and continue to the next fallback.
  }

  if (cached != null) {
    return cached;
  }

  if (session != null) {
    return _profileFromCompanySession(session);
  }

  return _profileFromDirectory(directory, null);
}

bool _matchesBusiness(String candidateId, String? businessId) {
  if (businessId == null || businessId.isEmpty) return true;
  return candidateId == businessId;
}

BusinessProfileModel? _profileFromDirectory(
  List<CompanyListEntry>? directory,
  String? businessId,
) {
  if (directory == null || directory.isEmpty) return null;

  final entry = _pickEntry(
    directory,
    businessId,
    (item) => item.id,
    (item) => item.isCurrent,
  );
  return entry == null ? null : _profileFromCompanyEntry(entry);
}

BusinessProfileModel? _profileFromBusinessList(
  List<BusinessModel>? businesses,
  String? businessId,
) {
  if (businesses == null || businesses.isEmpty) return null;

  final business = _pickEntry(
    businesses,
    businessId,
    (item) => item.id,
    (item) => item.isCurrent,
  );
  return business == null ? null : _profileFromBusinessModel(business);
}

BusinessProfileModel? _profileFromAuthBusinesses(
  List<BusinessSummary> businesses,
  String? businessId,
) {
  if (businesses.isEmpty) return null;

  final summary = _pickEntry(
    businesses,
    businessId,
    (item) => item.id,
    (_) => false,
  );
  if (summary == null) return null;

  return BusinessProfileModel(
    id: summary.id,
    name: summary.name,
    gstin: summary.gstin,
  );
}

T? _pickEntry<T>(
  List<T> entries,
  String? businessId,
  String Function(T item) idFor,
  bool Function(T item) isCurrent,
) {
  if (businessId != null && businessId.isNotEmpty) {
    for (final entry in entries) {
      if (idFor(entry) == businessId) {
        return entry;
      }
    }
  }

  for (final entry in entries) {
    if (isCurrent(entry)) {
      return entry;
    }
  }

  return entries.first;
}

BusinessProfileModel _profileFromCompanySession(CompanySession session) {
  return BusinessProfileModel(
    id: session.companyId,
    name: session.companyName,
    ownerName: session.ownerName,
    phone: session.ownerPhone ?? session.currentUserPhone,
  );
}

BusinessProfileModel _profileFromCompanyEntry(CompanyListEntry entry) {
  return BusinessProfileModel(
    id: entry.id,
    name: entry.name,
    phone: entry.phone,
    email: entry.email,
    gstin: entry.gstin,
    address: entry.address,
    logoUrl: entry.logoUrl,
  );
}

BusinessProfileModel _profileFromBusinessModel(BusinessModel business) {
  return BusinessProfileModel(
    id: business.id,
    name: business.name,
    ownerName: business.ownerName,
    phone: business.phone,
    email: business.email,
    gstin: business.gstin,
    address: business.address,
    logoUrl: business.logoUrl,
  );
}
