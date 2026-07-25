import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:flutter/material.dart';

class RoleSelectField extends StatelessWidget {
  const RoleSelectField({
    required this.selectedRole,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final Role selectedRole;
  final ValueChanged<Role> onChanged;
  final bool enabled;

  static final List<String> _roleOptions = Role.values
      .map((role) => role.displayLabel)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Role',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: enabled ? 1 : 0.55,
          child: IgnorePointer(
            ignoring: !enabled,
            child: SaleGenericSelectDropdown(
              value: selectedRole.displayLabel,
              options: _roleOptions,
              hintText: 'Select role',
              highlight: SaleDropdownHighlight.blue,
              maxMenuHeight: 280,
              onSelected: (label) {
                final role = RoleX.fromDisplayLabel(label);
                if (role != null) onChanged(role);
              },
            ),
          ),
        ),
      ],
    );
  }
}
