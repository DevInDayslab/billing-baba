import 'package:billing_baba/features/reports/presentation/desktop/widgets/shared/report_unavailable_content.dart';
import 'package:flutter/material.dart';

/// Placeholder for reports whose backing business module is not implemented yet.
class ReportDeferredModuleContent extends StatelessWidget {
  const ReportDeferredModuleContent({
    required this.reportName,
    super.key,
  });

  final String reportName;

  @override
  Widget build(BuildContext context) {
    return ReportUnavailableContent(
      reportName: reportName,
      description:
          'Feature available once the corresponding business module is implemented.',
    );
  }
}
