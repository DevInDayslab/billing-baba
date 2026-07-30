import 'package:freezed_annotation/freezed_annotation.dart';

/// Vyapar-style inviteable business roles.
enum Role {
  @JsonValue('secondary_admin')
  secondaryAdmin,
  @JsonValue('salesman')
  salesman,
  @JsonValue('biller')
  biller,
  @JsonValue('biller_and_salesman')
  billerAndSalesman,
  @JsonValue('accountant')
  accountant,
  @JsonValue('stock_keeper')
  stockKeeper,
  @JsonValue('accountant_edit_access')
  accountantEditAccess,
}

extension RoleX on Role {
  String get displayLabel => switch (this) {
    Role.secondaryAdmin => 'Secondary Admin',
    Role.salesman => 'Salesman',
    Role.biller => 'Biller',
    Role.billerAndSalesman => 'Biller and Salesman',
    Role.accountant => 'CA / Accountant',
    Role.stockKeeper => 'Stock Keeper',
    Role.accountantEditAccess => 'CA / Accountant (Edit Access)',
  };

  static Role? fromDisplayLabel(String label) {
    for (final role in Role.values) {
      if (role.displayLabel == label) return role;
    }
    return null;
  }
}
