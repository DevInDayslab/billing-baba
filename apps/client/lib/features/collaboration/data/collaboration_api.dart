import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/data/collaboration_api_errors.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/invitation.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:dio/dio.dart';

class CollaborationApi {
  CollaborationApi(this._dio);

  final Dio _dio;

  Future<List<BusinessMember>> listMembers() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.collaborationMembers,
      );
      final data = _readList(response);
      return data.map(_parseMember).toList();
    });
  }

  Future<BusinessMember> updateMemberRole(String memberId, Role role) async {
    return _run(() async {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.collaborationMember(memberId),
        data: {'role': _roleToApi(role)},
      );
      return _parseMember(_readData(response));
    });
  }

  Future<void> removeMember(String memberId) async {
    await _run(() async {
      await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.collaborationMember(memberId),
      );
    });
  }

  Future<List<Invitation>> listInvitations() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.collaborationInvitations,
      );
      final data = _readList(response);
      return data.map(_parseInvitation).toList();
    });
  }

  Future<Invitation> createInvitation(InviteMemberInput input) async {
    return _run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationInvitations,
        data: {
          'full_name': input.fullName,
          'phone_or_email': input.phoneOrEmail,
          'role': _roleToApi(input.role),
        },
      );
      return _parseInvitation(_readData(response));
    });
  }

  Future<Invitation> reinvite(String invitationId) async {
    return _run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationReinvite(invitationId),
        data: const <String, dynamic>{},
      );
      return _parseInvitation(_readData(response));
    });
  }

  Future<Invitation> cancelInvitation(String invitationId) async {
    return _run(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationCancelInvitation(invitationId),
        data: const <String, dynamic>{},
      );
      return _parseInvitation(_readData(response));
    });
  }

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

  Future<List<Map<String, dynamic>>> listSharedCompanies() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.collaborationCompaniesShared,
      );
      return _readList(response);
    });
  }

  Future<List<Map<String, dynamic>>> listPendingInvitations() async {
    return _run(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.collaborationCompaniesInvitations,
      );
      return _readList(response);
    });
  }

  Future<void> acceptInvitationByToken(String token) async {
    await _run(() async {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationAcceptInvitation(token),
        data: const <String, dynamic>{},
      );
    });
  }

  Future<void> rejectInvitationByToken(String token) async {
    await _run(() async {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationRejectInvitation(token),
        data: const <String, dynamic>{},
      );
    });
  }

  Future<void> leaveCompany(String memberId) async {
    await _run(() async {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.collaborationLeaveCompany(memberId),
        data: const <String, dynamic>{},
      );
    });
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (error) {
      throwCollaborationApiError(error);
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

  List<Map<String, dynamic>> _readList(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid collaboration API response',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  BusinessMember _parseMember(Map<String, dynamic> json) {
    return BusinessMember.fromJson(json);
  }

  Invitation _parseInvitation(Map<String, dynamic> json) {
    return Invitation.fromJson(json);
  }

  bool _shouldFallbackToCreate(DioException error) {
    final status = error.response?.statusCode;
    if (status == 400 || status == 409) return true;
    final code = ApiErrorParser.errorCode(error);
    return code == 'INVITATION_NOT_ACTIONABLE' ||
        code == 'VALIDATION_ERROR' ||
        code == 'INVITATION_NOT_FOUND';
  }

  bool _isConflict(DioException error) {
    return error.response?.statusCode == 409 ||
        ApiErrorParser.errorCode(error) == 'CONFLICT';
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
