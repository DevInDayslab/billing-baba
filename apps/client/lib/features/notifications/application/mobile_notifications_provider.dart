import 'package:billing_baba/features/notifications/application/mobile_notifications_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileNotificationsState {
  const MobileNotificationsState({
    this.activeTab = MobileNotificationTab.appNotifications,
    this.showStayUpdatedBanner = true,
    this.notificationsEnabled = false,
  });

  final MobileNotificationTab activeTab;
  final bool showStayUpdatedBanner;
  final bool notificationsEnabled;

  MobileNotificationsState copyWith({
    MobileNotificationTab? activeTab,
    bool? showStayUpdatedBanner,
    bool? notificationsEnabled,
  }) {
    return MobileNotificationsState(
      activeTab: activeTab ?? this.activeTab,
      showStayUpdatedBanner:
          showStayUpdatedBanner ?? this.showStayUpdatedBanner,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final mobileNotificationsProvider =
    NotifierProvider<MobileNotificationsController, MobileNotificationsState>(
      MobileNotificationsController.new,
    );

/// Local UI state for the mobile notifications screen (mock data only).
class MobileNotificationsController extends Notifier<MobileNotificationsState> {
  @override
  MobileNotificationsState build() => const MobileNotificationsState();

  void setActiveTab(MobileNotificationTab tab) {
    if (tab == state.activeTab) return;
    state = state.copyWith(activeTab: tab);
  }

  void setActiveTabById(String tabId) {
    setActiveTab(MobileNotificationTabX.fromId(tabId));
  }

  void enableNotifications() {
    state = state.copyWith(
      notificationsEnabled: true,
      showStayUpdatedBanner: false,
    );
  }
}
