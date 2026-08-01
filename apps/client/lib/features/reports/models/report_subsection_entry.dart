/// A navigable report subsection shown in mobile report group lists.
class ReportSubsectionEntry {
  const ReportSubsectionEntry({
    required this.id,
    required this.label,
    this.showNotificationDot = false,
  });

  final String id;
  final String label;
  final bool showNotificationDot;
}
