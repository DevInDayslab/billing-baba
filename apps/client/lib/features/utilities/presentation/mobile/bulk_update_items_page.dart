import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/utilities/presentation/desktop/widgets/bulk_update_items_content.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';

class MobileBulkUpdateItemsPage extends StatelessWidget {
  const MobileBulkUpdateItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Bulk Update Items',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: false,
      ),
      body: BulkUpdateItemsContent(showPageHeader: false),
    );
  }
}
