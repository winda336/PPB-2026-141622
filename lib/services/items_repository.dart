import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemsRepository {
  ItemsRepository({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // Menampilkan barang temuan aktif
  // hanya pada pos milik satpam.
  Stream<QuerySnapshot<Map<String, dynamic>>> titipanAktif(String idPos) {
    return _db
        .collection('items')
        .where('tipe', isEqualTo: 'ditemukan')
        .where('idPos', isEqualTo: idPos)
        .where('status', isEqualTo: 'aktif')
        .orderBy('diperbaruiPada', descending: true)
        .snapshots();
  }

  // Mencatat penyerahan barang kepada pemilik.
  Future<void> serahkanKePemilik({
    required String itemId,
    required String namaPenerima,
  }) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw StateError('Sesi login sudah berakhir.');
    }

    final nama = namaPenerima.trim();

    if (nama.length < 2 || nama.length > 120) {
      throw ArgumentError('Nama penerima harus 2-120 karakter.');
    }

    await _db.collection('items').doc(itemId).update({
      'status': 'selesai',
      'diserahkanKepada': nama,
      'diserahkanPada': FieldValue.serverTimestamp(),
      'diserahkanOleh': uid,
      'diperbaruiPada': FieldValue.serverTimestamp(),
    });
  }

  // Edit informasi laporan temuan.
  // Tidak mengubah ID pos atau ID pelapor.
  Future<void> editTemuan({
    required String itemId,
    required String nama,
    required String kategori,
    required String fakultas,
    required String catatanTambahan,
    required DateTime tanggalKejadian,
  }) async {
    await _db.collection('items').doc(itemId).update({
      'nama': nama.trim(),
      'kategori': kategori.trim(),
      'fakultas': fakultas.trim(),
      'catatanTambahan': catatanTambahan.trim(),
      'tanggalKejadian': Timestamp.fromDate(tanggalKejadian),
      'diperbaruiPada': FieldValue.serverTimestamp(),
    });
  }

  // Hapus laporan temuan.
  // Rules akan menolak apabila bukan
  // satpam pos tersebut atau sudah selesai.
  Future<void> hapusTemuan(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }
}
