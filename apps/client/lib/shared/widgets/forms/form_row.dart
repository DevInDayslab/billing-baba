import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Equal-width horizontal form row that stacks on narrow widths.
class FormRow extends StatelessWidget {
  const FormRow({
    required this.children,
    this.spacing = FormSpacing.gutter,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.narrowBreakpoint = FormSpacing.narrowBreakpoint,
    this.alwaysHorizontal = false,
    this.flexes,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final double narrowBreakpoint;

  /// When true, keeps a [Row] layout even inside narrow grid cells.
  final bool alwaysHorizontal;

  /// Optional flex weights matching [children] length. Defaults to equal flex.
  final List<int>? flexes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow =
            !alwaysHorizontal && constraints.maxWidth < narrowBreakpoint;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(
                flex: flexes != null && i < flexes!.length ? flexes![i] : 1,
                child: children[i],
              ),
            ],
          ],
        );
      },
    );
  }
}
