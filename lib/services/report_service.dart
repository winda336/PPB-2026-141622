import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/pos_model.dart';

class ReportInput {
  final String tipe;
  final String nama;
  final String kategori;
  final String fakultas;
  final DateTime tanggalKejadian;
  final String catatanTambahan;
  final PosModel? pos; // wajib untuk tipe ditemukan
  final String idPelapor;
  final String namaPelapor;

  const ReportInput({
    required this.tipe,
    required this.nama,
    required this.kategori,
    required this.fakultas,
    required this.tanggalKejadian,
    required this.catatanTambahan,
    this.pos,
    required this.idPelapor,
    required this.namaPelapor,
  });
}

/// Menulis laporan baru ke koleksi `items` dan membaca daftar `pos`.
class ReportService {
  ReportService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  /// Pos satpam pada fakultas tertentu (untuk dropdown form Ditemukan).
  Stream<List<PosModel>> watchPos(String fakultas) {
    return _db
        .collection('pos')
        .where('fakultas', isEqualTo: fakultas)
        .snapshots()
        .map((s) => s.docs.map(PosModel.fromDoc).toList());
  }

  /// Nama pelapor dari koleksi `users` (fallback jika dokumen belum ada).
  Future<String> getNamaPelapor(String uid, {required String fallback}) async {
    final doc = await _db.collection('users').doc(uid).get();
    final nama = doc.data()?['nama'];
    return (nama is String && nama.isNotEmpty) ? nama : fallback;
  }

  /// Simpan laporan. Mengembalikan id dokumen baru.
  Future<String> submit(ReportInput r) async {
    final ditemukan = r.tipe == AppConst.tipeDitemukan;
    if (ditemukan && r.pos == null) {
      throw ArgumentError('Laporan ditemukan wajib memilih pos titipan.');
    }
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'tipe': r.tipe,
      'nama': r.nama.trim(),
      'kategori': r.kategori,
      'fakultas': r.fakultas,
      'tanggalKejadian': Timestamp.fromDate(r.tanggalKejadian),
      'catatanTambahan': r.catatanTambahan.trim(),
      'fotoUrl': '', // foto opsional: belum diimplementasi
      'status': AppConst.statusAktif,
      'idPelapor': r.idPelapor,
      'namaPelapor': r.namaPelapor,
      'createdAt': now,
      'diperbaruiPada': now,
    };
    if (ditemukan) {
      data['idPos'] = r.pos!.id;
      data['namaPos'] = r.pos!.nama;
    }
    final ref = await _db.collection('items').add(data);
    return ref.id;
  }
}