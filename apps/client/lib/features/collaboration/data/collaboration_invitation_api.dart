import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:dio/dio.dart';

class CollaborationInvitationApi {
  CollaborationInvitationApi(this._dio);

  final Dio _dio;

  Future<Invitation> createInvitation(InviteMemberInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.collaborationInvitations,
      data: {
        'full_name': input.fullName,
        'phone_or_email': input.phoneOrEmail,
        'role': _roleToApi(input.role),
      },
    );
    return _parseInvitation(_readData(response));
  }

  Future<Invitation> reinvite(String invitationId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.collaborationReinvite(invitationId),
    );
    return _parseInvitation(_readData(response));
  }

  /// Public invite page endpoint — returns current invitation status by code.
  Future<String> fetchInvitationStatus(String inviteCode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.collaborationInvitations}/$inviteCode',
    );
    final data = _readData(response);
    return data['status'] as String? ?? 'pending';
  }

  /// Reissues an invitation via API, falling back to create when the stored ID
  /// is from the local fake store or the server rejects reinvite (e.g. pending).
  Future<Invitation> resendInvitation({
    required String invitationId,
    required InviteMemberInput input,
    Invitation? existingInvitation,
  }) async {
    if (!isApiInvitationId(invitationId)) {
      return createInvitation(input);
    }

    try {
      return await reinvite(invitationId);
    } on DioException catch (error) {
      if (_shouldFallbackToCreate(error)) {
        try {
          return await createInvitation(input);
        } on DioException catch (createError) {
          if (_isConflict(createError) && existingInvitation != null) {
            return existingInvitation;
          }
          rethrow;
        }
      }
      rethrow;
    }
  }

  Map<String, dynamic> _readData(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid collaboration API response',
      );
    }
    return data;
  }

  Invitation _parseInvitation(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final status = normalized['status'];
    if (status == 'opened') {
      normalized['status'] = 'pending';
    }
    return Invitation.fromJson(normalized);
  }

  bool _shouldFallbackToCreate(DioException error) {
    final status = error.response?.statusCode;
    if (status == 400 || status == 409) return true;
    final code = _errorCode(error);
    return code == 'INVITATION_NOT_ACTIONABLE' ||
        code == 'VALIDATION_ERROR' ||
        code == 'INVITATION_NOT_FOUND';
  }

  bool _isConflict(DioException error) {
    return error.response?.statusCode == 409 || _errorCode(error) == 'CONFLICT';
  }

  String? _errorCode(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final errorBody = data['error'];
      if (errorBody is Map<String, dynamic>) {
        return errorBody['code'] as String?;
      }
    }
    return null;
  }

  String _roleToApi(Role role) => switch (role) {
    Role.secondaryAdmin => 'secondary_admin',
    Role.salesman => 'salesman',
    Role.biller => 'biller',
    Role.billerAndSalesman => 'biller_and_salesman',
    Role.accountant => 'accountant',
    Role.stockKeeper => 'stock_keeper',
    Role.accountantEditAccess => 'accountant_edit_access',
  };
}
