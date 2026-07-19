import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/validators.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_error_mapper.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_repository_provider.dart';
import 'package:billing_baba/features/collaboration/application/collaboration_service_types.dart';
import 'package:billing_baba/features/collaboration/domain/models/business_member.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/invitations_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/members_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/providers/permission_preset_provider.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/permission_matrix_table.dart';
import 'package:billing_baba/features/collaboration/presentation/widgets/role_select_field.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _inviteDialogMaxWidth = 480.0;
const _editDialogMaxWidth = 820.0;

Future<bool?> showAddMemberDialog(BuildContext context, WidgetRef ref) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const MemberFormDialog(),
  );
}

Future<bool?> showEditMemberDialog(
  BuildContext context,
  WidgetRef ref,
  BusinessMember member,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => MemberFormDialog(member: member),
  );
}

class MemberFormDialog extends ConsumerStatefulWidget {
  const MemberFormDialog({this.member, super.key});

  final BusinessMember? member;

  bool get isEditing => member != null;

  @override
  ConsumerState<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends ConsumerState<MemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late Role _selectedRole;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.fullName);
    final contact = widget.member?.phoneOrEmail;
    _contactController = TextEditingController(
      text: contact != null && isPhoneContact(contact)
          ? localPhoneDigits(contact)
          : contact,
    );
    _selectedRole = widget.member?.role ?? Role.biller;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool get _contactIsEmail => _contactController.text.contains('@');

  bool get _isValid {
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    if (name.isEmpty || contact.isEmpty) return false;
    if (_contactIsEmail) {
      return Validators.email(contact) == null;
    }
    return localPhoneDigits(contact).length == 10;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_isValid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final contact = formatPhoneOrEmailContact(_contactController.text);

      if (widget.isEditing) {
        await ref
            .read(membersProvider.notifier)
            .updateMember(
              widget.member!.id,
              UpdateMemberInput(
                fullName: name,
                phoneOrEmail: contact,
                role: _selectedRole,
              ),
            );
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final result = await ref
            .read(lastInvitationProvider.notifier)
            .invite(
              InviteMemberInput(
                fullName: name,
                phoneOrEmail: contact,
                role: _selectedRole,
              ),
            );
        if (!mounted) return;
        Navigator.of(context).pop(true);

        final service = ref.read(collaborationServiceProvider);
        service.shareViaWhatsApp(result.invitation);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to $name'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on Object catch (error) {
      setState(() {
        _errorMessage = CollaborationErrorMapper.messageFor(error);
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditDialog(context);
    }
    return _buildInviteDialog(context);
  }

  Widget _buildInviteDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _inviteDialogMaxWidth),
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dialogHeader('Invite Member'),
                  const SizedBox(height: AppSpacing.md),
                  _nameField(),
                  const SizedBox(height: AppSpacing.md),
                  _contactField(showHelper: false),
                  const SizedBox(height: AppSpacing.md),
                  RoleSelectField(
                    selectedRole: _selectedRole,
                    enabled: !_isSubmitting,
                    onChanged: (role) => setState(() => _selectedRole = role),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _actions(inviteLabel: 'Invite User'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditDialog(BuildContext context) {
    final preset = ref.watch(permissionPresetProvider(_selectedRole));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _editDialogMaxWidth),
        child: Material(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _dialogHeader('Edit Member'),
                  const SizedBox(height: AppSpacing.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stackFields = constraints.maxWidth < 720;

                      if (stackFields) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _nameField(),
                            const SizedBox(height: AppSpacing.md),
                            _contactField(showHelper: false),
                            const SizedBox(height: AppSpacing.md),
                            RoleSelectField(
                              selectedRole: _selectedRole,
                              enabled: !_isSubmitting,
                              onChanged: (role) =>
                                  setState(() => _selectedRole = role),
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _nameField()),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _contactField(showHelper: false)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: RoleSelectField(
                              selectedRole: _selectedRole,
                              enabled: !_isSubmitting,
                              onChanged: (role) =>
                                  setState(() => _selectedRole = role),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PermissionMatrixTable(
                    role: _selectedRole,
                    preset: preset,
                    compact: true,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _actions(inviteLabel: 'Save Changes'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: buildSaleFieldDecoration(hint: 'Enter full name'),
          validator: (value) => Validators.required(value, fieldName: 'Name'),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _contactField({required bool showHelper}) {
    final isEmail = _contactIsEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone or Email',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _contactController,
          decoration: buildSaleFieldDecoration(
            hint: isEmail ? 'Enter email address' : 'Enter 10-digit number',
          ).copyWith(
            prefixIcon: isEmail
                ? null
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
            prefixIconConstraints: isEmail
                ? null
                : const BoxConstraints(),
          ),
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.phone,
          inputFormatters: isEmail
              ? null
              : [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
          onEditingComplete: _formatContactField,
          onFieldSubmitted: (_) => _formatContactField(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone or email is required';
            }
            if (value.contains('@')) {
              return Validators.email(value);
            }
            if (localPhoneDigits(value).length != 10) {
              return 'Enter a valid 10-digit phone number';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        if (showHelper) ...[
          const SizedBox(height: 4),
          const Text(
            'User will receive an invite on this number or email.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  void _formatContactField() {
    final value = _contactController.text;
    if (value.trim().isEmpty || value.contains('@')) return;
    final digits = localPhoneDigits(value);
    if (digits.length != 10) return;
    final formatted = formatPhoneOrEmailContact(digits);
    if (formatted != value) {
      _contactController.text = formatted;
      _contactController.selection = TextSelection.collapsed(
        offset: formatted.length,
      );
      setState(() {});
    }
  }

  Widget _actions({required String inviteLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.md),
        FilledButton(
          onPressed: !_isValid || _isSubmitting ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(inviteLabel),
        ),
      ],
    );
  }
}
