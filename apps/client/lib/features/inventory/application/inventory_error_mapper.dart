import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:dio/dio.dart';

class InventoryOfflineException implements Exception {
  const InventoryOfflineException();

  @override
  String toString() => 'Network unavailable';
}

class InventoryException implements Exception {
  const InventoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class InventoryErrorMapper {
  static const _itemFieldLabels = <String, String>{
    'name': 'Item name',
    'barcode': 'Barcode / item code',
    'item_code': 'Item code',
    'base_unit': 'Base unit',
    'category_id': 'Category',
    'brand_id': 'Brand',
    'opening_quantity': 'Opening quantity',
    'opening_cost_per_unit': 'Opening cost',
    'opening_godown_id': 'Godown',
    'sale_price': 'Sale price',
    'purchase_price': 'Purchase price',
    'hsn_code': 'HSN code',
  };

  /// User-facing copy for API field validation on item save forms.
  static String validationMessage(ApiValidationException error) {
    if (error.fieldErrors.isEmpty) {
      return error.message.isNotEmpty
          ? error.message
          : 'Please fix the highlighted fields and try again.';
    }

    final messages = <String>[];
    for (final field in _itemValidationFieldOrder) {
      final detail = error.fieldErrors[field];
      if (detail == null || detail.isEmpty) continue;
      messages.add(_formatFieldMessage(field, detail));
    }

    for (final entry in error.fieldErrors.entries) {
      if (_itemValidationFieldOrder.contains(entry.key)) continue;
      if (entry.value.isEmpty) continue;
      messages.add(_formatFieldMessage(entry.key, entry.value));
    }

    return messages.isEmpty ? error.message : messages.join('\n');
  }

  static const _itemValidationFieldOrder = [
    'name',
    'barcode',
    'item_code',
    'base_unit',
    'category_id',
    'brand_id',
    'opening_quantity',
    'opening_cost_per_unit',
    'opening_godown_id',
    'sale_price',
    'purchase_price',
    'hsn_code',
  ];

  static String _formatFieldMessage(String field, String detail) {
    final label = _itemFieldLabels[field];
    if (label == null) return detail;
    if (detail.toLowerCase().contains(label.toLowerCase())) return detail;
    return '$label: $detail';
  }

  /// Context-specific messages when saving an inventory item fails.
  static String messageForSaveItem(Object error) {
    if (error is ApiValidationException) {
      return validationMessage(error);
    }
    if (error is InventoryException) return error.message;
    if (error is InventoryOfflineException) {
      return OfflineUiMessages.workingOffline;
    }
    if (error is DioException) {
      final validation = ApiErrorParser.parseValidation(error);
      if (validation != null) return validationMessage(validation);

      final code = ApiErrorParser.errorCode(error);
      final apiMessage = ApiErrorParser.errorMessage(error);
      switch (code) {
        case 'VALIDATION_ERROR':
          return apiMessage ??
              'Some item fields are invalid. Please review and try again.';
        case 'UNAUTHORIZED':
        case 'FORBIDDEN':
          return 'You do not have permission to add or edit items.';
        case 'NOT_FOUND':
          return 'A related inventory record was not found. Refresh the page and try again.';
        case 'CONFLICT':
          return apiMessage ?? 'This item conflicts with existing inventory data.';
        case 'BUSINESS_NOT_SELECTED':
          return 'No company is selected. Open a company and try again.';
      }

      if (isOfflineError(error)) {
        return OfflineUiMessages.workingOffline;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 500) {
        return 'Server error while saving the item. Please try again.';
      }
      if (statusCode == 503) {
        return 'Server is temporarily unavailable. Please try again shortly.';
      }
      if (apiMessage != null && apiMessage.isNotEmpty) {
        return apiMessage;
      }
    }

    return 'Could not save the item. Please try again.';
  }

  static Never mapAndThrow(DioException error) {
    final validation = ApiErrorParser.parseValidation(error);
    if (validation != null) {
      throw validation;
    }

    final code = ApiErrorParser.errorCode(error);
    switch (code) {
      case 'CATEGORY_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete category with existing items.',
        );
      case 'BRAND_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete brand with existing items.',
        );
      case 'UNIT_HAS_ITEMS':
        throw const InventoryException(
          'Cannot delete unit because it is used by items.',
        );
      case 'UNIT_HAS_CONVERSIONS':
        throw const InventoryException(
          'Cannot delete unit because it has active conversions.',
        );
      case 'NOT_FOUND':
        throw const InventoryException('Record not found.');
      case 'FORBIDDEN':
      case 'UNAUTHORIZED':
        throw const InventoryException(
          'You do not have access to this business.',
        );
      case 'CONFLICT':
        throw const InventoryException(
          'This action conflicts with existing data.',
        );
    }

    if (_isOffline(error)) {
      throw const InventoryOfflineException();
    }

    final message = ApiErrorParser.errorMessage(error);
    if (message != null && message.isNotEmpty) {
      throw InventoryException(message);
    }

    throw const InventoryException(
      'Unable to complete the request. Please try again.',
    );
  }

  static bool isOfflineError(DioException error) => _isOffline(error);

  static String messageFor(Object error) {
    if (error is InventoryException) return error.message;
    if (error is InventoryOfflineException) {
      return OfflineUiMessages.workingOffline;
    }
    if (error is ApiValidationException) return validationMessage(error);
    if (error is DioException) return messageForSaveItem(error);
    if (error is StateError &&
        error.message.contains('No business selected')) {
      return 'Select a business to load items.';
    }
    return OfflineUiMessages.messageFor(error);
  }

  static bool _isOffline(DioException error) => ApiErrorParser.isOffline(error);
}
