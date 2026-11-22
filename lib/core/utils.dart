const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// 9 Nov 2026
String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

/// hari ini / kemarin / 3 hari lalu
String waktuRelatif(DateTime d) {
  final hari = DateTime.now().difference(d).inDays;
  if (hari <= 0) return 'hari ini';
  if (hari == 1) return 'kemarin';
  return '$hari hari lalu';
}
