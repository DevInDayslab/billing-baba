import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CouponInputSection extends StatefulWidget {
  const CouponInputSection({
    required this.appliedCouponCode,
    required this.onApply,
    required this.onRemove,
    super.key,
  });

  final String? appliedCouponCode;
  final Future<String?> Function(String code) onApply;
  final VoidCallback onRemove;

  @override
  State<CouponInputSection> createState() => _CouponInputSectionState();
}

class _CouponInputSectionState extends State<CouponInputSection> {
  final _controller = TextEditingController();
  var _isExpanded = false;
  var _isApplying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    if (_isApplying) return;
    setState(() {
      _isApplying = true;
      _errorMessage = null;
    });

    final error = await widget.onApply(_controller.text);
    if (!mounted) return;

    setState(() {
      _isApplying = false;
      if (error != null) {
        _errorMessage = error;
      } else {
        _controller.clear();
        _isExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appliedCouponCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          color: const Color(0xFFE8F5E9),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_outlined,
              size: 18,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${widget.appliedCouponCode} applied',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onRemove,
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: AppRadius.mdBorder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Have a coupon code?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        errorText: _errorMessage,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      onSubmitted: (_) => _apply(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _isApplying ? null : _apply,
                        child: _isApplying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
