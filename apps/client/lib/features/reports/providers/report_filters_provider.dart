import 'package:billing_baba/features/reports/models/requests/report_requests.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_filters_provider.g.dart';

@Riverpod(keepAlive: true)
class ReportFilters extends _$ReportFilters {
  @override
  ReportFiltersState build() => const ReportFiltersState();

  void setPeriod(ReportPeriod period) {
    state = state.copyWith(period: period, currentPage: 1);
  }

  void setCustomDateRange(DateTimeRange range) {
    state = state.copyWith(
      period: ReportPeriod.custom,
      customDateRange: range,
      currentPage: 1,
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date, currentPage: 1);
  }

  void setPartyId(String? partyId) {
    state = state.copyWith(
      partyId: partyId,
      clearPartyId: partyId == null,
      currentPage: 1,
    );
  }

  void setGodownId(String? godownId) {
    state = state.copyWith(
      godownId: godownId,
      clearGodownId: godownId == null,
      currentPage: 1,
    );
  }

  void setItemId(String? itemId) {
    state = state.copyWith(
      itemId: itemId,
      clearItemId: itemId == null,
      currentPage: 1,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void resetPage() {
    state = state.copyWith(currentPage: 1);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      currentPage: 1,
    );
  }

  void setPaymentMode(String? paymentMode) {
    state = state.copyWith(
      paymentMode: paymentMode,
      clearPaymentMode: paymentMode == null || paymentMode.isEmpty,
      currentPage: 1,
    );
  }

  void setDocumentType(String? documentType) {
    state = state.copyWith(
      documentType: documentType,
      clearDocumentType: documentType == null || documentType.isEmpty,
      currentPage: 1,
    );
  }

  void setPartyGroup(String? partyGroup) {
    state = state.copyWith(
      partyGroup: partyGroup,
      clearPartyGroup: partyGroup == null || partyGroup.isEmpty,
      currentPage: 1,
    );
  }

  void setBankName(String? bankName) {
    state = state.copyWith(
      bankName: bankName,
      clearBankName: bankName == null || bankName.isEmpty,
      currentPage: 1,
    );
  }

  void setTaxRate(String? taxRate) {
    state = state.copyWith(
      taxRate: taxRate,
      clearTaxRate: taxRate == null || taxRate.isEmpty,
      currentPage: 1,
    );
  }

  void setLoanAccount(String? loanAccount) {
    state = state.copyWith(
      loanAccount: loanAccount,
      clearLoanAccount: loanAccount == null || loanAccount.isEmpty,
      currentPage: 1,
    );
  }

  void setStatus(String? status) {
    state = state.copyWith(
      status: status,
      clearStatus: status == null || status.isEmpty,
      currentPage: 1,
    );
  }

  void setPartyType(String? partyType) {
    state = state.copyWith(
      partyType: partyType,
      clearPartyType: partyType == null || partyType.isEmpty,
      currentPage: 1,
    );
  }

  void setInStockOnly(bool inStockOnly) {
    state = state.copyWith(inStockOnly: inStockOnly, currentPage: 1);
  }

  void setPageSize(int pageSize) {
    state = state.copyWith(pageSize: pageSize, currentPage: 1);
  }

  void setFormat(String? format) {
    state = state.copyWith(
      format: format,
      clearFormat: format == null || format.isEmpty,
    );
  }
}
