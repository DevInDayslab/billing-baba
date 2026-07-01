import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _tabActiveColor = Color(0xFF1565C0);
const _cardBorder = Color(0xFFE0E0E0);
const _bannerBg = Color(0xFFFFF3E0);
const _accentBar = Color(0xFFFF9800);

enum PreviewShareTab { saleOrder, shareStore }

const _defaultStoreUrl = 'https://billingbaba.in/store/helo1';
const _defaultPhone = '+91-9352874656';

const _defaultStoreMessage =
    'Hello,\n'
    'Place your order online at our store:\n'
    '$_defaultStoreUrl\n'
    'For any query, call us at $_defaultPhone\n'
    'Thanks';

const _defaultSaleOrderMessage =
    'Hello,\n'
    'Please find your sale order details below.\n'
    'Place your order online at our store:\n'
    '$_defaultStoreUrl\n'
    'For any query, call us at $_defaultPhone\n'
    'Thanks';

/// Shows the Preview & Share modal with Sale Order and Share Store tabs.
Future<void> showPreviewShareDialog(
  BuildContext context, {
  PreviewShareTab initialTab = PreviewShareTab.shareStore,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: PreviewShareDialog(initialTab: initialTab),
    ),
  );
}

class PreviewShareDialog extends StatefulWidget {
  const PreviewShareDialog({
    this.initialTab = PreviewShareTab.shareStore,
    super.key,
  });

  final PreviewShareTab initialTab;

  @override
  State<PreviewShareDialog> createState() => _PreviewShareDialogState();
}

class _PreviewShareDialogState extends State<PreviewShareDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late String _storeMessage;
  late String _saleOrderMessage;
  bool _dontShowAgain = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == PreviewShareTab.saleOrder ? 0 : 1,
    );
    _storeMessage = _defaultStoreMessage;
    _saleOrderMessage = _defaultSaleOrderMessage;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _activeMessage =>
      _tabController.index == 0 ? _saleOrderMessage : _storeMessage;

  void _updateActiveMessage(String value) {
    setState(() {
      if (_tabController.index == 0) {
        _saleOrderMessage = value;
      } else {
        _storeMessage = value;
      }
    });
  }

  void _handleSaveAndShare() {
    unawaited(Clipboard.setData(ClipboardData(text: _activeMessage)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: _tabActiveColor,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: _tabActiveColor,
              indicatorWeight: 3,
              dividerColor: _cardBorder,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Sale Order'),
                Tab(text: 'Share Store'),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_tabController.index == 1) ...[
                          _OnlineStoreBanner(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Online store setup coming soon'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        _MessagePreview(message: _activeMessage),
                        const SizedBox(height: AppSpacing.md),
                        _EditMessageSection(
                          message: _activeMessage,
                          onChanged: _updateActiveMessage,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _dontShowAgain,
                        onChanged: (value) =>
                            setState(() => _dontShowAgain = value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        "Don't Show this popup again.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "NOTE: Edited messages can't be sent via SMS",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: _handleSaveAndShare,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Save & Share',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Text(
            'Preview & Share',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Close',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: _cardBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineStoreBanner extends StatelessWidget {
  const _OnlineStoreBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bannerBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, size: 18, color: _accentBar),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                children: [
                  const TextSpan(
                    text: 'Get your own website for online store now. ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Click here',
                        style: TextStyle(
                          fontSize: 13,
                          color: _tabActiveColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePreview extends StatelessWidget {
  const _MessagePreview({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _EditMessageSection extends StatefulWidget {
  const _EditMessageSection({
    required this.message,
    required this.onChanged,
  });

  final String message;
  final ValueChanged<String> onChanged;

  @override
  State<_EditMessageSection> createState() => _EditMessageSectionState();
}

class _EditMessageSectionState extends State<_EditMessageSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message);
  }

  @override
  void didUpdateWidget(_EditMessageSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message &&
        widget.message != _controller.text) {
      _controller.text = widget.message;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: _accentBar,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Edit Message',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          maxLines: 6,
          style: const TextStyle(fontSize: 13, height: 1.5),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _tabActiveColor),
            ),
          ),
        ),
      ],
    );
  }
}
