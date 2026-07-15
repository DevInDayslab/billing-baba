import 'dart:io' show Platform;

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/presentation/providers/deals_provider.dart';
import 'package:billing_baba/features/crm/presentation/widgets/deal_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _columnWidth = 280.0;
const _columnBorder = Color(0xFFE0E0E0);
const _emptyTextColor = Color(0xFF9E9E9E);

bool get _useLongPressDrag {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

Color _headerColorForStage(DealStage stage) {
  if (stage.isWon) return const Color(0xFFE6F4EA);
  if (stage.isLost) return const Color(0xFFFCE8E6);
  return const Color(0xFFE0F2F1);
}

class DealsKanbanBoard extends ConsumerStatefulWidget {
  const DealsKanbanBoard({
    required this.onMoveDeal,
    super.key,
  });

  final Future<void> Function(Deal deal, DealStage newStage) onMoveDeal;

  @override
  ConsumerState<DealsKanbanBoard> createState() => _DealsKanbanBoardState();
}

class _DealsKanbanBoardState extends ConsumerState<DealsKanbanBoard> {
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(dealsByStageProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final stage in DealStageX.pipelineStages)
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _DealStageColumn(
                      summary: stages[stage]!,
                      onMoveDeal: widget.onMoveDeal,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DealStageColumn extends StatelessWidget {
  const _DealStageColumn({
    required this.summary,
    required this.onMoveDeal,
  });

  final DealStageSummary summary;
  final Future<void> Function(Deal deal, DealStage newStage) onMoveDeal;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final stage = summary.stage;

    return DragTarget<Deal>(
      onWillAcceptWithDetails: (details) => details.data.stage != stage,
      onAcceptWithDetails: (details) => onMoveDeal(details.data, stage),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: _columnWidth,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary.withValues(alpha: 0.08)
                : const Color(0xFFF8F9FA),
            border: Border.all(
              color: isHighlighted ? AppColors.primary : _columnBorder,
              width: isHighlighted ? 2 : 1,
            ),
            borderRadius: AppRadius.mdBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StageHeader(
                stage: stage,
                count: summary.deals.length,
                totalAmount: _currencyFormat.format(summary.totalAmount),
                headerColor: _headerColorForStage(stage),
              ),
              Expanded(
                child: summary.deals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            isHighlighted
                                ? 'Drop deal here'
                                : 'No Deals found.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isHighlighted
                                  ? AppColors.primary
                                  : _emptyTextColor,
                              fontWeight: isHighlighted
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        itemCount: summary.deals.length,
                        itemBuilder: (context, index) {
                          final deal = summary.deals[index];
                          return _DraggableDealCard(deal: deal);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableDealCard extends StatelessWidget {
  const _DraggableDealCard({required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final feedback = Material(
      elevation: 8,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _columnWidth - AppSpacing.md * 2,
        child: Opacity(
          opacity: 0.95,
          child: DealCard(deal: deal),
        ),
      ),
    );
    final childWhenDragging = Opacity(
      opacity: 0.35,
      child: DealCard(deal: deal),
    );
    final child = MouseRegion(
      cursor: _useLongPressDrag
          ? SystemMouseCursors.basic
          : SystemMouseCursors.grab,
      child: DealCard(deal: deal),
    );

    if (_useLongPressDrag) {
      return LongPressDraggable<Deal>(
        data: deal,
        feedback: feedback,
        childWhenDragging: childWhenDragging,
        child: child,
      );
    }

    return Draggable<Deal>(
      data: deal,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      child: child,
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.stage,
    required this.count,
    required this.totalAmount,
    required this.headerColor,
  });

  final DealStage stage;
  final int count;
  final String totalAmount;
  final Color headerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.md),
        ),
        border: const Border(bottom: BorderSide(color: _columnBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _HeaderBadge(text: '$count'),
                    const SizedBox(width: 6),
                    _HeaderBadge(text: '${stage.probability}%'),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        totalAmount,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _columnBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
