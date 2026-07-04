import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/utils/create_business_validator.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_business_controller.g.dart';

class CreateBusinessFormState {
  const CreateBusinessFormState({
    this.isSubmitting = false,
    this.fieldErrors = const {},
    this.generalError,
    this.showGenericErrorDialog = false,
  });

  final bool isSubmitting;
  final Map<String, String> fieldErrors;
  final String? generalError;
  final bool showGenericErrorDialog;

  String? errorFor(String field) => fieldErrors[field];

  CreateBusinessFormState copyWith({
    bool? isSubmitting,
    Map<String, String>? fieldErrors,
    String? generalError,
    bool? showGenericErrorDialog,
    bool clearFieldErrors = false,
    bool clearGeneralError = false,
    bool clearGenericDialog = false,
  }) {
    return CreateBusinessFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldErrors: clearFieldErrors
          ? const {}
          : fieldErrors ?? this.fieldErrors,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
      showGenericErrorDialog:
          !clearGenericDialog &&
          (showGenericErrorDialog ?? this.showGenericErrorDialog),
    );
  }
}

@riverpod
class CreateBusinessForm extends _$CreateBusinessForm {
  @override
  CreateBusinessFormState build() => const CreateBusinessFormState();

  void clearErrors() {
    state = state.copyWith(
      clearFieldErrors: true,
      clearGeneralError: true,
      clearGenericDialog: true,
    );
  }

  void acknowledgeGenericDialog() {
    state = state.copyWith(clearGenericDialog: true);
  }

  Future<BusinessModel?> submit(CreateBusinessInput input) async {
    if (state.isSubmitting) return null;

    final clientErrors = CreateBusinessValidator.validate(input);
    if (clientErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: clientErrors,
        clearGeneralError: true,
        clearGenericDialog: true,
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearFieldErrors: true,
      clearGeneralError: true,
      clearGenericDialog: true,
    );

    try {
      final created = await ref
          .read(businessListProvider.notifier)
          .createBusiness(input.toRequest());
      state = state.copyWith(isSubmitting: false);
      return created;
    } on ApiValidationException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        fieldErrors: e.fieldErrors,
      );
      return null;
    } on BusinessOfflineException {
      state = state.copyWith(
        isSubmitting: false,
        generalError:
            'You are offline. Business creation has been queued and will sync when you reconnect.',
      );
      return null;
    } on DioException catch (e) {
      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) {
        state = state.copyWith(
          isSubmitting: false,
          fieldErrors: validation.fieldErrors,
        );
        return null;
      }
      state = state.copyWith(
        isSubmitting: false,
        showGenericErrorDialog: true,
      );
      return null;
    } on Object catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        showGenericErrorDialog: true,
      );
      return null;
    }
  }
}
