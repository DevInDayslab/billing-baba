import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/features/settings/application/settings_save_messages.dart';
import 'package:billing_baba/shared/widgets/settings_saved_toast.dart';
import 'package:flutter/scheduler.dart';

void notifySettingsSaved({
  String message = SettingsSaveMessages.defaultSuccess,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    showSettingsSavedToast(
      message: message,
      context: rootNavigatorKey.currentContext,
    );
  });
}

void notifySettingsBlocked({
  required String message,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    showSettingsBlockedToast(
      message: message,
      context: rootNavigatorKey.currentContext,
    );
  });
}
