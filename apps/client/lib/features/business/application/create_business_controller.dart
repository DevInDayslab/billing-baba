import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/models/create_business_input.dart';
import 'package:billing_baba/features/business/utils/create_business_error_messages.dart';
import 'package:billing_baba/features/business/utils/create_business_validator.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_business_controller.g.dart';

class CreateBusinessFormState {
  const CreateBusinessFormState({
    this.isSubmitting = false,
    this.fieldErrors = const {},
    this.generalError,
    this.showErrorDialog = false,
  });

  final bool isSubmitting;
  final Map<String, String> fieldErrors;
  final String? generalError;
  final bool showErrorDialog;

  String? errorFor(String field) => fieldErrors[field];

  CreateBusinessFormState copyWith({
    bool? isSubmitting,
    Map<String, String>? fieldErrors,
    String? generalError,
    bool? showErrorDialog,
    bool clearFieldErrors = false,
    bool clearGeneralError = false,
    bool clearErrorDialog = false,
  }) {
    return CreateBusinessFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldErrors: clearFieldErrors
          ? const {}
          : fieldErrors ?? this.fieldErrors,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
      showErrorDialog:
          !clearErrorDialog && (showErrorDialog ?? this.showErrorDialog),
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
      clearErrorDialog: true,
    );
  }

  void acknowledgeErrorDialog() {
    state = state.copyWith(clearErrorDialog: true);
  }

  void _failSubmit(Object error, {Map<String, String>? fieldErrors}) {
    final message = CreateBusinessErrorMessages.fromError(error);
    state = state.copyWith(
      isSubmitting: false,
      fieldErrors: fieldErrors ?? const {},
      generalError: fieldErrors == null || fieldErrors.isEmpty ? message : null,
      showErrorDialog: fieldErrors == null || fieldErrors.isEmpty,
    );
  }

  Future<BusinessModel?> submit(CreateBusinessInput input) async {
    if (state.isSubmitting) return null;

    final clientErrors = CreateBusinessValidator.validate(input);
    if (clientErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: clientErrors,
        clearGeneralError: true,
        clearErrorDialog: true,
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearFieldErrors: true,
      clearGeneralError: true,
      clearErrorDialog: true,
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
        clearGeneralError: true,
        clearErrorDialog: true,
      );
      return null;
    } on BusinessOfflineException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: CreateBusinessErrorMessages.fromError(e),
        showErrorDialog: false,
      );
      return null;
    } on BusinessSelectionFailed catch (e) {
      _failSubmit(e);
      return null;
    } on DioException catch (e) {
      final validation = ApiErrorParser.parseValidation(e);
      if (validation != null) {
        state = state.copyWith(
          isSubmitting: false,
          fieldErrors: validation.fieldErrors,
          clearGeneralError: true,
          clearErrorDialog: true,
        );
        return null;
      }
      _failSubmit(e);
      return null;
    } on Object catch (e) {
      _failSubmit(e);
      return null;
    }
  }
}
