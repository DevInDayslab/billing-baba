import 'package:flutter/material.dart';

export 'mobile_document_form_scaffold.dart';
export 'mobile_document_header.dart';
export 'mobile_document_items_section.dart';
export 'mobile_document_line_edit_sheet.dart';
export 'mobile_document_notes_attachments_section.dart';
export 'mobile_document_party_section.dart';
export 'mobile_document_summary_card.dart';
export 'mobile_document_totals_section.dart';
export 'mobile_document_visibility.dart';
export 'mobile_form_fields.dart';
export 'mobile_form_scaffold.dart';
export 'mobile_item_picker_sheet.dart';
export 'mobile_line_items_editor.dart';
export 'mobile_offline_banner.dart';
export 'mobile_party_picker_sheet.dart';
export 'mobile_select_spinner_dialog.dart';

/// Shows a snackbar and pops the route on successful save.
void showMobileFormResult(
  BuildContext context, {
  required String? error,
  String successMessage = 'Saved successfully',
}) {
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(successMessage)),
  );
  // Explicit pop — maybePop is blocked by PopScope(canPop: false) on forms.
  Navigator.of(context).pop();
}
