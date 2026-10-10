import 'package:billing_baba/features/settings/models/tax_rate_models.dart';

/// Statutory GST slabs used to seed a business that has no tax rates yet.
/// Component rows and groups are generated from these slabs.
const gstSlabPercents = <double>[0, 0.25, 3, 5, 12, 18, 28, 40];

/// Inserted among slabs: appears after slabs below this value.
const exemptSortBeforeSlab = 40.0;

const gstComponentKinds = ['IGST', 'SGST', 'CGST'];

class ParsedGstTaxRate {
  const ParsedGstTaxRate({
    required this.kind,
    required this.percent,
    required this.isExempt,
  });

  final String? kind;
  final double percent;
  final bool isExempt;

  /// Slab this component belongs to. SGST/CGST are half of the slab.
  double get slab {
    if (isExempt) return exemptSortBeforeSlab - 0.01;
    if (kind == 'SGST' || kind == 'CGST') return percent * 2;
    return percent;
  }
}

ParsedGstTaxRate parseGstTaxRate(String name, String rate) {
  final trimmed = name.trim();
  if (trimmed.toLowerCase() == 'exempt') {
    return ParsedGstTaxRate(
      kind: null,
      percent: double.tryParse(rate) ?? 0,
      isExempt: true,
    );
  }
  final match = RegExp(
    r'^(IGST|SGST|CGST|CESS)@([\d.]+)%$',
    caseSensitive: false,
  ).firstMatch(trimmed);
  if (match != null) {
    return ParsedGstTaxRate(
      kind: match.group(1)!.toUpperCase(),
      percent: double.tryParse(match.group(2)!) ?? double.tryParse(rate) ?? 0,
      isExempt: false,
    );
  }
  return ParsedGstTaxRate(
    kind: null,
    percent: double.tryParse(rate) ?? 0,
    isExempt: false,
  );
}

String formatTaxPercent(double value) {
  final text = value.toStringAsFixed(3);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String taxRateName({required String? kind, required double percent}) {
  if (kind == null || kind.isEmpty) return 'Exempt';
  return '$kind@${formatTaxPercent(percent)}%';
}

List<CreateTaxRateRequest> defaultGstTaxRateCreates() {
  final requests = <CreateTaxRateRequest>[];
  for (final slab in gstSlabPercents) {
    if (slab == exemptSortBeforeSlab) {
      requests.add(
        const CreateTaxRateRequest(name: 'Exempt', rate: '0'),
      );
    }
    requests.add(
      CreateTaxRateRequest(
        name: taxRateName(kind: 'IGST', percent: slab),
        rate: formatTaxPercent(slab),
      ),
    );
    final half = slab / 2;
    requests.add(
      CreateTaxRateRequest(
        name: taxRateName(kind: 'SGST', percent: half),
        rate: formatTaxPercent(half),
      ),
    );
    requests.add(
      CreateTaxRateRequest(
        name: taxRateName(kind: 'CGST', percent: half),
        rate: formatTaxPercent(half),
      ),
    );
  }
  return requests;
}

class GstTaxGroup {
  const GstTaxGroup({
    required this.name,
    required this.totalPercent,
    required this.members,
  });

  final String name;
  final double totalPercent;
  final List<TaxRateDto> members;
}

/// A tax group is the SGST + CGST pair that together make one GST slab.
List<GstTaxGroup> deriveGstTaxGroups(List<TaxRateDto> rates) {
  final sgst = <double, TaxRateDto>{};
  final cgst = <double, TaxRateDto>{};
  for (final rate in rates) {
    final parsed = parseGstTaxRate(rate.name, rate.rate);
    if (parsed.kind == 'SGST') sgst[parsed.percent] = rate;
    if (parsed.kind == 'CGST') cgst[parsed.percent] = rate;
  }
  final halves = {...sgst.keys, ...cgst.keys}.toList()..sort();
  final groups = <GstTaxGroup>[];
  for (final half in halves) {
    final s = sgst[half];
    final c = cgst[half];
    if (s == null || c == null) continue;
    final total = half * 2;
    groups.add(
      GstTaxGroup(
        name: 'GST@${formatTaxPercent(total)}%',
        totalPercent: total,
        members: [s, c],
      ),
    );
  }
  return groups;
}

int compareTaxRatesForDisplay(TaxRateDto a, TaxRateDto b) {
  final pa = parseGstTaxRate(a.name, a.rate);
  final pb = parseGstTaxRate(b.name, b.rate);
  final slab = pa.slab.compareTo(pb.slab);
  if (slab != 0) return slab;
  final kindOrder = {for (var i = 0; i < gstComponentKinds.length; i++) gstComponentKinds[i]: i};
  final ka = kindOrder[pa.kind] ?? 99;
  final kb = kindOrder[pb.kind] ?? 99;
  return ka.compareTo(kb);
}
