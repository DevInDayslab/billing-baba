import 'package:billing_baba/features/plans_pricing/models/plan_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI state for the mobile Plans & Pricing accordion screen.
class MobilePlansSelectionState {
  const MobilePlansSelectionState({
    this.selectedPlan = PricingPlanType.platinum,
    this.platform = PlanPlatform.mobile,
    this.duration = PlanDuration.threeYears,
  });

  final PricingPlanType selectedPlan;
  final PlanPlatform platform;
  final PlanDuration duration;

  MobilePlansSelectionState copyWith({
    PricingPlanType? selectedPlan,
    PlanPlatform? platform,
    PlanDuration? duration,
  }) {
    return MobilePlansSelectionState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      platform: platform ?? this.platform,
      duration: duration ?? this.duration,
    );
  }
}

final mobilePlansSelectionProvider =
    NotifierProvider<MobilePlansSelectionNotifier, MobilePlansSelectionState>(
  MobilePlansSelectionNotifier.new,
);

class MobilePlansSelectionNotifier extends Notifier<MobilePlansSelectionState> {
  @override
  MobilePlansSelectionState build() => const MobilePlansSelectionState();

  void selectPlan(PricingPlanType plan) {
    if (state.selectedPlan == plan) return;
    state = state.copyWith(selectedPlan: plan);
  }

  void setDuration(PlanDuration duration) {
    if (state.duration == duration) return;
    state = state.copyWith(duration: duration);
  }

  void setPlatform(PlanPlatform platform) {
    if (state.platform == platform) return;
    state = state.copyWith(platform: platform);
  }
}
