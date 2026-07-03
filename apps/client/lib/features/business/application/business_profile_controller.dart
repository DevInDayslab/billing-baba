import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_profile_model.dart';
import 'package:billing_baba/features/business/utils/edit_business_profile_validator.dart';
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

  Future<BusinessProfileModel?> submit(UpdateBusinessProfileInput input) async {
    if (state.isSubmitting) return null;

    final clientErrors = EditBusinessProfileValidator.validate(input);
    if (clientErrors.isNotEmpty) {
      state = state.copyWith(
        fieldErrors: clientErrors,
        clearGeneralError: true,
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearFieldErrors: true,
      clearGeneralError: true,
    );

    try {
      final updated = await ref
          .read(businessProfileProvider.notifier)
          .updateProfile(input);
      state = state.copyWith(isSubmitting: false);
      return updated;
    } on ApiValidationException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        fieldErrors: e.fieldErrors,
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
        generalError: _messageFromDio(e),
      );
      return null;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: 'Unable to save business profile. Please try again.',
      );
      return null;
    }
  }

  String _messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Unable to connect to Billing Baba server.';
    }
    return 'Unable to save business profile. Please try again.';
  }
}
