import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Propagates a profile patch (logo or saved fields) to list cache + Select Business.
Future<void> propagateBusinessProfileListUpdate(
  WidgetRef ref,
  BusinessProfileModel profile,
) async {
  ref.read(businessListProvider.notifier).applyProfileUpdate(profile);
  final service = await ref.read(businessServiceProvider.future);
  await service.persistSavedProfile(profile);
  ref.invalidate(companyDirectoryProvider);
}

/// Overlays [businessListProvider] profile fields onto directory rows for instant UI.
List<CompanyListEntry> mergeDirectoryProfileFields(
  List<CompanyListEntry> entries,
  List<BusinessModel>? businesses,
) {
  if (businesses == null || businesses.isEmpty) return entries;

  final byId = {for (final business in businesses) business.id: business};
  return entries.map((entry) {
    final business = byId[entry.id];
    if (business == null) return entry;

    final sameName = business.name == entry.name;
    final sameLogo = business.logoUrl == entry.logoUrl;
    final sameGstin = business.gstin == entry.gstin;
    final sameOwner = business.ownerName == entry.ownerName;
    final samePhone = business.phone == entry.phone;
    final sameEmail = business.email == entry.email;
    final sameAddress = business.address == entry.address;
    if (sameName &&
        sameLogo &&
        sameGstin &&
        sameOwner &&
        samePhone &&
        sameEmail &&
        sameAddress) {
      return entry;
    }

    return CompanyListEntry(
      id: entry.id,
      name: business.name,
      ownerName: business.ownerName,
      ownerPhone: entry.ownerPhone,
      relationship: entry.relationship,
      role: entry.role,
      invitationId: entry.invitationId,
      invitationStatus: entry.invitationStatus,
      inviteCode: entry.inviteCode,
      memberId: entry.memberId,
      syncStatus: entry.syncStatus,
      source: entry.source,
      lastSaleAt: entry.lastSaleAt,
      isCurrent: entry.isCurrent,
      gstin: business.gstin,
      phone: business.phone,
      email: business.email,
      address: business.address,
      logoUrl: business.logoUrl,
      scheduledDeletionAt: entry.scheduledDeletionAt,
    );
  }).toList();
}
