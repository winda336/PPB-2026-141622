import 'package:cloud_firestore/cloud_firestore.dart';

/// Isi data contoh koleksi `pos` supaya dropdown pos bisa dites.
/// Panggil SEKALI saja, lalu hapus pemanggilnya. Atau isi manual di Firebase Console.
Future<void> seedPos([FirebaseFirestore? firestore]) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final data = {
    'pos_gedung_e_fkip': ['Pos Satpam Gedung E FKIP', 'FKIP'],
    'pos_gedung_a_fkip': ['Pos Satpam Gedung A FKIP', 'FKIP'],
    'pos_gedung_b_feb': ['Pos Satpam Gedung B', 'FEB'],
    'pos_teknik': ['Pos Satpam Fakultas Teknik', 'Fakultas Teknik'],
  };
  for (final e in data.entries) {
    await db.collection('pos').doc(e.key).set({
      'nama': e.value[0],
      'fakultas': e.value[1],
      'jamBuka': '07.00 - 17.00',
    });
  }
}
