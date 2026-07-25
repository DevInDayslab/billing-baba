import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/print/presentation/desktop/widgets/voucher_print_actions.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/job_work_out_dialog.dart';
import 'package:billing_baba/features/sales/application/job_work_orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _menuMinWidth = 200.0;
const _menuItemHeight = 40.0;
const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  side: BorderSide(color: Color(0xFFE0E0E0)),
);

class JobWorkOutActionsMenuButton extends ConsumerWidget {
  const JobWorkOutActionsMenuButton({
    required this.item,
    super.key,
  });

  final JobWorkOrderListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'More',
          icon: const Icon(
            Icons.more_vert,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onPressed: () => _openMenu(buttonContext, ref),
        );
      },
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final action = await showMenu<String>(
      context: context,
      useRootNavigator: true,
      position: _menuPosition(context),
      color: AppColors.surface,
      shadowColor: Colors.black26,
      elevation: 4,
      surfaceTintColor: Colors.transparent,
      shape: _menuShape,
      constraints: const BoxConstraints(minWidth: _menuMinWidth),
      items: [
        _menuItem('view_edit', 'View/Edit'),
        _menuItem('preview', 'Preview'),
        _menuItem('print', 'Print'),
        if (item.status == JobWorkOutStatus.open)
          _menuItem('close', 'Mark as Closed'),
        _menuItem('delete', 'Delete'),
      ],
    );

    if (action == null || !context.mounted) return;
    await _handleAction(context, ref, action);
  }

  PopupMenuItem<String> _menuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      height: _menuItemHeight,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final listNotifier = ref.read(jobWorkOrdersListProvider.notifier);
    final filename = VoucherPrintActions.filenameFor(
      item.jobId.isNotEmpty ? item.jobId : item.id,
    );

    switch (action) {
      case 'view_edit':
        await showJobWorkOutDialog(context, orderId: item.id);
        await listNotifier.refresh();
      case 'preview':
        await VoucherPrintActions.previewJobWorkOrder(
          context,
          ref,
          item.id,
          filename: filename,
        );
      case 'print':
        await VoucherPrintActions.previewJobWorkOrder(
          context,
          ref,
          item.id,
          filename: filename,
        );
      case 'close':
        final error = await listNotifier.closeOrder(item.id);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete job work out?'),
            content: Text(
              'Delete job work out${item.jobId.isNotEmpty ? ' #${item.jobId}' : ''}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        final error = await listNotifier.deleteOrder(item.id);
        if (!context.mounted) return;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
    }
  }

  RelativeRect _menuPosition(BuildContext context) {
    final buttonBox = context.findRenderObject()! as RenderBox;
    final overlayBox =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()!
            as RenderBox;

    final buttonOrigin = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final buttonSize = buttonBox.size;

    final menuLeft = (buttonOrigin.dx + buttonSize.width - _menuMinWidth).clamp(
      0.0,
      overlayBox.size.width - _menuMinWidth,
    );
    final menuTop = buttonOrigin.dy + buttonSize.height + 4;

    return RelativeRect.fromLTRB(
      menuLeft,
      menuTop,
      overlayBox.size.width - menuLeft - _menuMinWidth,
      overlayBox.size.height - menuTop,
    );
  }
}
