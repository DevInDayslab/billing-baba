import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ShareChannel { email, whatsApp, sms }

extension ShareChannelLabel on ShareChannel {
  String get label => switch (this) {
    ShareChannel.email => 'Email',
    ShareChannel.whatsApp => 'WhatsApp',
    ShareChannel.sms => 'SMS',
  };
}

const _cardBorder = Color(0xFFE0E0E0);
const _hoverBorder = Color(0xFF90CAF9);
const _hoverBackground = Color(0xFFF5FAFF);

/// Vyapar-style share trigger that opens a horizontal Email / WhatsApp / SMS panel.
class ShareMenuButton extends StatefulWidget {
  const ShareMenuButton({
    this.onChannelSelected,
    this.child,
    this.overlayOffset = const Offset(0, 40),
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    super.key,
  });

  final ValueChanged<ShareChannel>? onChannelSelected;
  final Widget? child;
  final Offset overlayOffset;

  /// Kept for API compatibility with the previous overlay-based positioning.
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  @override
  State<ShareMenuButton> createState() => _ShareMenuButtonState();
}

class _ShareMenuButtonState extends State<ShareMenuButton> {
  final MenuController _menuController = MenuController();

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
  }

  void _handleChannelSelected(ShareChannel channel) {
    _menuController.close();
    widget.onChannelSelected?.call(channel);
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      useRootOverlay: true,
      consumeOutsideTap: true,
      crossAxisUnconstrained: true,
      alignmentOffset: widget.overlayOffset,
      style: MenuStyle(
        alignment: widget.followerAnchor,
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      menuChildren: [
        ShareMenuPanel(onChannelSelected: _handleChannelSelected),
      ],
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: _toggleMenu,
          behavior: HitTestBehavior.opaque,
          child: widget.child ?? const _DefaultShareTrigger(),
        );
      },
    );
  }
}

class ShareMenuPanel extends StatefulWidget {
  const ShareMenuPanel({
    required this.onChannelSelected,
    super.key,
  });

  final ValueChanged<ShareChannel> onChannelSelected;

  @override
  State<ShareMenuPanel> createState() => _ShareMenuPanelState();
}

class _ShareMenuPanelState extends State<ShareMenuPanel> {
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      color: AppColors.surface,
      borderRadius: AppRadius.lgBorder,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final channel in ShareChannel.values) ...[
                  _ShareChannelTile(
                    channel: channel,
                    onTap: () => widget.onChannelSelected(channel),
                  ),
                  if (channel != ShareChannel.values.last)
                    const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareChannelTile extends StatefulWidget {
  const _ShareChannelTile({
    required this.channel,
    required this.onTap,
  });

  final ShareChannel channel;
  final VoidCallback onTap;

  @override
  State<_ShareChannelTile> createState() => _ShareChannelTileState();
}

class _ShareChannelTileState extends State<_ShareChannelTile> {
  bool _isHovered = false;

  void _setHovered(bool hovered) {
    if (_isHovered == hovered) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isHovered != hovered) {
        setState(() => _isHovered = hovered);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 88,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? _hoverBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? _hoverBorder : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShareChannelIcon(channel: widget.channel),
              const SizedBox(height: 6),
              Text(
                widget.channel.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareChannelIcon extends StatelessWidget {
  const _ShareChannelIcon({required this.channel});

  final ShareChannel channel;

  @override
  Widget build(BuildContext context) {
    return switch (channel) {
      ShareChannel.email => const _GmailIcon(),
      ShareChannel.whatsApp => const _WhatsAppIcon(),
      ShareChannel.sms => const _SmsIcon(),
    };
  }
}

class _GmailIcon extends StatelessWidget {
  const _GmailIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _GmailIconPainter()),
    );
  }
}

class _GmailIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final red = Paint()..color = const Color(0xFFEA4335);
    final blue = Paint()..color = const Color(0xFF4285F4);
    final green = Paint()..color = const Color(0xFF34A853);
    final yellow = Paint()..color = const Color(0xFFFBBC05);

    final envelope = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w * 0.5, h * 0.58)
      ..lineTo(w, h * 0.28)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(envelope, blue);

    final leftFlap = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w * 0.5, h * 0.58)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftFlap, red);

    final rightFlap = Path()
      ..moveTo(w, h * 0.28)
      ..lineTo(w * 0.5, h * 0.58)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightFlap, green);

    final topFlap = Path()
      ..moveTo(0, h * 0.28)
      ..lineTo(w * 0.5, h * 0.58)
      ..lineTo(w, h * 0.28)
      ..close();
    canvas.drawPath(topFlap, yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF25D366),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.chat_bubble_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class _SmsIcon extends StatelessWidget {
  const _SmsIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFFF9800),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.more_horiz_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _DefaultShareTrigger extends StatelessWidget {
  const _DefaultShareTrigger();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Share', style: TextStyle(fontSize: 13)),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }
}
