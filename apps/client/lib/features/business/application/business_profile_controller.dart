import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/utils/business_profile_debug_log.dart';
import 'package:billing_baba/features/business/utils/edit_business_profile_validator.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_profile_controller.g.dart';

class EditBusinessProfileFormState {
  const EditBusinessProfileFormState({
    this.isSubmitting = false,
    this.fieldErrors = const {},
    this.generalError,
  });

  final bool isSubmitting;
  final Map<String, String> fieldErrors;
  final String? generalError;

  String? errorFor(String field) => fieldErrors[field];

  EditBusinessProfileFormState copyWith({
    bool? isSubmitting,
    Map<String, String>? fieldErrors,
    String? generalError,
    bool clearFieldErrors = false,
    bool clearGeneralError = false,
  }) {
    return EditBusinessProfileFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      fieldErrors: clearFieldErrors
          ? const {}
          : fieldErrors ?? this.fieldErrors,
      generalError: clearGeneralError
          ? null
          : generalError ?? this.generalError,
    );
  }
}

@riverpod
class EditBusinessProfileForm extends _$EditBusinessProfileForm {
  @override
  EditBusinessProfileFormState build() => const EditBusinessProfileFormState();

  void clearErrors() {
    state = state.copyWith(
      clearFieldErrors: true,
      clearGeneralError: true,
    );
  }

  Future<BusinessProfileModel?> submit(UpdateBusinessProfileInput input) async {
    if (state.isSubmitting) return null;

    final clientErrors = EditBusinessProfileValidator.validate(input);
    if (clientErrors.isNotEmpty) {
      BusinessProfileDebugLog.section('CLIENT VALIDATION FAILED');
      for (final entry in clientErrors.entries) {
        BusinessProfileDebugLog.log('${entry.key}: ${entry.value}');
      }
      state = state.copyWith(
        fieldErrors: clientErrors,
        clearGeneralError: true,
      );
      return null;
    }

    BusinessProfileDebugLog.section('SUBMIT UPDATE PROFILE');
    BusinessProfileDebugLog.log('input: ${input.toRequest().toJson()}');

    state = state.copyWith(
      isSubmitting: true,
      clearFieldErrors: true,
      clearGeneralError: true,
    );

    try {
      final updated = await ref
          .read(businessProfileProvider.notifier)
          .updateProfile(input);
      ref.invalidate(companyDirectoryProvider);
      state = state.copyWith(isSubmitting: false);
      return updated;
    } on ApiValidationException catch (e) {
      BusinessProfileDebugLog.log('API validation: ${e.fieldErrors}');
      state = state.copyWith(
        isSubmitting: false,
        fieldErrors: e.fieldErrors,
      );
      return null;
    } on BusinessProfileScopeRequired catch (_) {
      const message =
          'No company is selected in your session. Open a company from the Company List, then try again.';
      BusinessProfileDebugLog.log('BusinessProfileScopeRequired: $message');
      state = state.copyWith(
        isSubmitting: false,
        generalError: message,
      );
      return null;
    } on DioException catch (e, stack) {
      BusinessProfileDebugLog.section('DIO EXCEPTION');
      BusinessProfileDebugLog.log('type: ${e.type}');
      BusinessProfileDebugLog.log('status: ${e.response?.statusCode}');
      BusinessProfileDebugLog.log('response: ${e.response?.data}');
      BusinessProfileDebugLog.log('stack: $stack');

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
        generalError: _messageFromDio(e),
      );
      return null;
    } on Object catch (e, stack) {
      BusinessProfileDebugLog.section('UNEXPECTED ERROR');
      BusinessProfileDebugLog.log('error: $e');
      BusinessProfileDebugLog.log('stack: $stack');
      state = state.copyWith(
        isSubmitting: false,
        generalError: e is BusinessProfileScopeRequired
            ? 'No company is selected in your session. Open a company from the Company List, then try again.'
            : 'Unable to save business profile. Please try again.',
      );
      return null;
    }
  }

  String _messageFromDio(DioException error) {
    final fieldDetail = ApiErrorParser.firstValidationDetail(error);
    if (fieldDetail != null && fieldDetail.isNotEmpty) return fieldDetail;

    return ApiErrorParser.userFacingMessage(error);
  }
}
