import 'package:billing_baba/features/sales/models/sale_form_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaleFormAttachment.fromApi', () {
    test('maps API attachment payload', () {
      final attachment = SaleFormAttachment.fromApi(const {
        'id': 'att-1',
        'file_name': 'invoice.pdf',
        'file_url': 'https://cdn/invoice.pdf',
        'download_url': 'https://cdn/signed.pdf',
        'mime_type': 'application/pdf',
      });

      expect(attachment.remoteId, 'att-1');
      expect(attachment.displayName, 'invoice.pdf');
      expect(attachment.fileUrl, 'https://cdn/signed.pdf');
      expect(attachment.isPdf, isTrue);
      expect(attachment.syncStatus, AttachmentSyncStatus.synced);
    });
  });
}
