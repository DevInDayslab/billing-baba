import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_level.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_preset.dart';
import 'package:billing_baba/features/collaboration/domain/models/role.dart';

/// Maps each [Role] to its fixed Vyapar-style permission matrix.
///
/// Backend authorization should use this registry — never store per-cell
/// permissions on members.
abstract final class RolePermissionRegistry {
  static const List<PermissionAction> allActions = PermissionAction.values;

  static PermissionPreset presetFor(Role role) {
    return PermissionPreset(role: role, rows: _rowsFor(role));
  }

  static List<PermissionRow> _rowsFor(Role role) {
    return switch (role) {
      Role.secondaryAdmin => _secondaryAdminRows,
      Role.salesman => _salesmanRows,
      Role.biller => _billerRows,
      Role.billerAndSalesman => _billerAndSalesmanRows,
      Role.accountant => _accountantRows,
      Role.stockKeeper => _stockKeeperRows,
      Role.accountantEditAccess => _accountantEditAccessRows,
    };
  }

  static const PermissionLevel _a = PermissionLevel.allowed;
  static const PermissionLevel _d = PermissionLevel.denied;
  static const PermissionLevel _n = PermissionLevel.notApplicable;

  static Map<PermissionAction, PermissionLevel> _levels(
    PermissionLevel view,
    PermissionLevel create,
    PermissionLevel edit,
    PermissionLevel share,
    PermissionLevel delete,
  ) {
    return {
      PermissionAction.view: view,
      PermissionAction.create: create,
      PermissionAction.edit: edit,
      PermissionAction.share: share,
      PermissionAction.delete: delete,
    };
  }

  static PermissionRow _row(PermissionModule module, List<PermissionLevel> v) {
    return PermissionRow(
      module: module,
      levels: _levels(v[0], v[1], v[2], v[3], v[4]),
    );
  }

  static final List<PermissionRow> _secondaryAdminRows = [
    _row(PermissionModule.allTransactions, [_a, _a, _a, _a, _a]),
    _row(PermissionModule.settings, [_a, _n, _a, _n, _n]),
    _row(PermissionModule.syncSettings, [_d, _d, _d, _n, _d]),
    _row(PermissionModule.reports, [_a, _n, _n, _a, _n]),
    _row(PermissionModule.stockTransfer, [_a, _a, _n, _a, _a]),
    _row(PermissionModule.partySmartConnect, [_a, _a, _a, _n, _n]),
  ];

  static final List<PermissionLevel> _salesmanTransaction = [
    _d,
    _a,
    _d,
    _a,
    _d,
  ];

  static final List<PermissionRow> _salesmanRows = [
    _row(PermissionModule.sale, _salesmanTransaction),
    _row(PermissionModule.paymentIn, _salesmanTransaction),
    _row(PermissionModule.saleOrder, _salesmanTransaction),
    _row(PermissionModule.creditNote, _salesmanTransaction),
    _row(PermissionModule.deliveryChallan, _salesmanTransaction),
    _row(PermissionModule.estimate, _salesmanTransaction),
    _row(PermissionModule.expense, _salesmanTransaction),
    _row(PermissionModule.proforma, _salesmanTransaction),
  ];

  static final List<PermissionRow> _billerRows = [
    _row(PermissionModule.sale, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.paymentIn, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.saleOrder, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.creditNote, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.deliveryChallan, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.estimate, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.expense, [_d, _a, _d, _a, _d]),
    _row(PermissionModule.party, [_a, _a, _a, _a, _d]),
    _row(PermissionModule.item, [_a, _d, _d, _d, _d]),
    _row(PermissionModule.proforma, [_a, _a, _d, _a, _d]),
  ];

  static final List<PermissionRow> _billerAndSalesmanRows = [
    _row(PermissionModule.sale, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.paymentIn, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.saleOrder, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.creditNote, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.deliveryChallan, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.estimate, [_a, _a, _d, _a, _d]),
    _row(PermissionModule.expense, [_d, _a, _d, _a, _d]),
    _row(PermissionModule.party, [_a, _a, _a, _a, _d]),
    _row(PermissionModule.item, [_a, _a, _a, _a, _d]),
    _row(PermissionModule.proforma, [_a, _a, _d, _a, _d]),
  ];

  static final List<PermissionRow> _accountantRows = [
    _row(PermissionModule.allTransactions, [_a, _d, _d, _a, _d]),
    _row(PermissionModule.settings, [_d, _d, _d, _d, _d]),
    _row(PermissionModule.syncSettings, [_d, _d, _d, _d, _d]),
    _row(PermissionModule.reports, [_a, _a, _a, _a, _a]),
    _row(PermissionModule.stockTransfer, [_a, _d, _n, _a, _d]),
  ];

  static final List<PermissionRow> _stockKeeperRows = [
    _row(PermissionModule.purchase, [_a, _a, _d, _d, _d]),
    _row(PermissionModule.paymentOut, [_a, _a, _d, _d, _d]),
    _row(PermissionModule.purchaseOrder, [_a, _a, _d, _d, _d]),
    _row(PermissionModule.debitNote, [_a, _a, _d, _d, _d]),
    _row(PermissionModule.stockTransfer, [_d, _a, _n, _a, _d]),
  ];

  static final List<PermissionRow> _accountantEditAccessRows = [
    _row(PermissionModule.allTransactions, [_a, _a, _a, _a, _a]),
    _row(PermissionModule.settings, [_a, _n, _a, _n, _n]),
    _row(PermissionModule.syncSettings, [_d, _d, _d, _n, _d]),
    _row(PermissionModule.reports, [_a, _n, _n, _a, _n]),
    _row(PermissionModule.stockTransfer, [_a, _a, _n, _a, _a]),
    _row(PermissionModule.partySmartConnect, [_d, _n, _d, _n, _n]),
  ];
}
