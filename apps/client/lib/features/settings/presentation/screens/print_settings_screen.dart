import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/settings/models/print_settings.dart';
import 'package:billing_baba/features/settings/presentation/widgets/invoice_preview_widget.dart';
import 'package:billing_baba/features/settings/presentation/widgets/regular_settings_panel.dart';
import 'package:billing_baba/features/settings/presentation/widgets/thermal_settings_panel.dart';
import 'package:billing_baba/features/settings/providers/print_settings_provider.dart';
import 'package:billing_baba/features/settings/services/invoice_print_document_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrintSettingsScreen extends ConsumerStatefulWidget {
  const PrintSettingsScreen({super.key});

  static const _narrowBreakpoint = 600.0;

  @override
  ConsumerState<PrintSettingsScreen> createState() =>
      _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends ConsumerState<PrintSettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isApplying = false;
  PrintSettings? _draft;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDraft(PrintSettingsUpdater updater) {
    final current = _draft;
    if (current == null) return;
    setState(() => _draft = updater(current));
  }

  Future<void> _handleApply() async {
    final draft = _draft;
    if (draft == null || _isApplying) return;

    setState(() => _isApplying = true);

    try {
      await ref.read(printSettingsProvider.notifier).save(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Print settings applied app-wide')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not apply settings: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  void _setPrinterType(PrinterType type) {
    _updateDraft((settings) => settings.copyWith(printerType: type));
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(printSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Print Settings',
          style: AppTypography.inter(
            fontSize: AppTypography.titleMediumSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: listPanelCardBorder,
          ),
        ),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(printSettingsProvider),
        ),
        data: (savedSettings) {
          _draft ??= savedSettings;

          final tabIndex =
              _draft!.printerType == PrinterType.thermal ? 0 : 1;
          if (_tabController.index != tabIndex &&
              !_tabController.indexIsChanging) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _tabController.index != tabIndex) {
                _tabController.index = tabIndex;
              }
            });
          }

          return _PrintSettingsBody(
            settings: _draft!,
            tabController: _tabController,
            onPrinterTypeChanged: _setPrinterType,
            onUpdate: _updateDraft,
          );
        },
      ),
      bottomNavigationBar: settingsAsync.maybeWhen(
        data: (_) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: listPanelCardBorder),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SafeArea(
            child: FilledButton(
              onPressed: _isApplying || _draft == null ? null : _handleApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                textStyle: AppTypography.inter(
                  fontSize: AppTypography.bodyMediumSize,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isApplying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Apply'),
            ),
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _PrintSettingsBody extends StatelessWidget {
  const _PrintSettingsBody({
    required this.settings,
    required this.tabController,
    required this.onPrinterTypeChanged,
    required this.onUpdate,
  });

  final PrintSettings settings;
  final TabController tabController;
  final ValueChanged<PrinterType> onPrinterTypeChanged;
  final ValueChanged<PrintSettingsUpdater> onUpdate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow =
            constraints.maxWidth < PrintSettingsScreen._narrowBreakpoint;

        final tabBar = Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: listPanelCardBorder),
            ),
          ),
          child: TabBar(
            controller: tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            dividerColor: listPanelCardBorder,
            labelStyle: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            onTap: (index) {
              onPrinterTypeChanged(
                index == 0 ? PrinterType.thermal : PrinterType.regular,
              );
            },
            tabs: const [
              Tab(text: 'Thermal'),
              Tab(text: 'Regular (A4)'),
            ],
          ),
        );

        final settingsPanel = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tabBar,
            Expanded(
              child: settings.printerType == PrinterType.thermal
                  ? ThermalSettingsPanel(
                      settings: settings,
                      onUpdate: onUpdate,
                    )
                  : RegularSettingsPanel(
                      settings: settings,
                      onUpdate: onUpdate,
                    ),
            ),
          ],
        );

        final previewPanel = InvoicePreviewWidget(settings: settings);

        if (isNarrow) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 520, child: settingsPanel),
                const SizedBox(height: AppSpacing.md),
                SizedBox(height: 420, child: previewPanel),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 45,
                child: settingsPanel,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 55,
                child: previewPanel,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load print settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
