import 'package:billing_baba/core/config/app_config.dart';
import 'package:billing_baba/core/logging/device_info_collector.dart';
import 'package:billing_baba/core/logging/diagnostics_store.dart';
import 'package:billing_baba/core/logging/logging_service.dart';
import 'package:billing_baba/core/network/network_diagnostics_service.dart';
import 'package:billing_baba/core/services/connectivity_service.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Hidden diagnostics page for alpha and internal demo builds.
class DesktopDiagnosticsPage extends StatefulWidget {
  const DesktopDiagnosticsPage({super.key});

  @override
  State<DesktopDiagnosticsPage> createState() => _DiagnosticsPageState();
}

class _DiagnosticsPageState extends State<DesktopDiagnosticsPage> {
  final DiagnosticsStore _store = DiagnosticsStore.instance;
  DeviceInfoSnapshot? _deviceInfo;
  var _runningTest = false;
  var _networkReachable = false;
  var _checkingNetwork = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final deviceInfo = await DeviceInfoCollector.collect();
    final connected = await ConnectivityService().isConnected;
    if (!mounted) return;
    setState(() {
      _deviceInfo = deviceInfo;
      _networkReachable = connected;
      _checkingNetwork = false;
    });
    _store.setNetworkReachable(connected);
  }

  Future<void> _runConnectivityTest() async {
    setState(() => _runningTest = true);
    try {
      final result =
          await NetworkDiagnosticsService().runConnectivityTest();
      if (!mounted) return;
      setState(() {
        _runningTest = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.success
                ? 'Backend reachable (${result.httpStatus})'
                : 'Test failed: ${result.failureStage} — ${result.failureMessage}',
          ),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _runningTest = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connectivity test error: $e')),
      );
    }
  }

  Future<void> _copyLogs() async {
    await LoggingService.instance.copyLogsToClipboard();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  Future<void> _openLogFolder() async {
    await LoggingService.instance.openLogFolder();
  }

  @override
  Widget build(BuildContext context) {
    final device = _deviceInfo;
    final connectivity = _store.lastConnectivityTest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            title: 'Logging',
            children: [
              _InfoRow('FILE_LOGGING', '${AppConfig.fileLoggingEnabled}'),
              _InfoRow('LOG_LEVEL', AppConfig.minLogLevel.name),
              _InfoRow('VERBOSE_LOGGING', '${AppConfig.consoleVerbose}'),
              _InfoRow(
                'Log File',
                LoggingService.instance.logFilePath ?? '(not initialized)',
              ),
            ],
          ),
          _Section(
            title: 'Environment',
            children: [
              _InfoRow('API URL', AppConfig.apiBaseUrl),
              _InfoRow('API URL Source', AppConfig.apiBaseUrlSource),
              _InfoRow('APP_ENV', dotenv.env['APP_ENV'] ?? '(unset)'),
              _InfoRow('ENABLE_DEV_LOGIN', '${AppConfig.enableDevLogin}'),
              _InfoRow('WEBSITE_URL', AppConfig.websiteUrl),
              _InfoRow('GIT_COMMIT', AppConfig.gitCommit),
            ],
          ),
          _Section(
            title: 'Network',
            children: [
              _InfoRow(
                'Network Reachable',
                _checkingNetwork ? 'Checking…' : '$_networkReachable',
              ),
              _InfoRow(
                'Backend Reachable',
                connectivity == null
                    ? 'Not tested'
                    : '${connectivity.success} (HTTP ${connectivity.httpStatus ?? '—'})',
              ),
              _InfoRow('Health Check Status', _healthStatusLabel(connectivity)),
              _InfoRow('Last API Call', _store.lastApiCall ?? '—'),
              _InfoRow(
                'Last Error',
                _store.lastError?.summaryLines ?? '—',
              ),
            ],
          ),
          _Section(
            title: 'Device',
            children: [
              if (device != null) ...[
                _InfoRow('Platform', device.platform),
                _InfoRow('OS', device.operatingSystem),
                if (device.windowsVersion.isNotEmpty)
                  _InfoRow('Windows Version', device.windowsVersion),
                if (device.cpuArchitecture.isNotEmpty)
                  _InfoRow('CPU Architecture', device.cpuArchitecture),
                _InfoRow('Flutter Version', device.flutterVersion),
                _InfoRow('Build Version', device.buildVersion),
              ] else
                const _InfoRow('Loading', '…'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: _runningTest ? null : _runConnectivityTest,
                icon: _runningTest
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find_rounded, size: 18),
                label: const Text('Run Connectivity Test'),
              ),
              OutlinedButton.icon(
                onPressed: _copyLogs,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Logs'),
              ),
              OutlinedButton.icon(
                onPressed: _openLogFolder,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Open Log Folder'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _healthStatusLabel(ConnectivityTestResult? connectivity) {
    if (connectivity == null) return 'Unknown';
    if (connectivity.success) return 'Healthy';
    return '${connectivity.failureStage ?? 'failed'}: '
        '${connectivity.failureMessage ?? ''}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
