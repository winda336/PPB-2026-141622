import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

class ItemModel {
  final String id;
  final String tipe; // hilang / ditemukan
  final String nama;
  final String kategori;
  final String fakultas;
  final DateTime tanggalKejadian;
  final String catatanTambahan;
  final String? fotoUrl;
  final String? idPos;
  final String? namaPos;
  final String status; // aktif / selesai
  final String? diserahkanKepada;
  final DateTime? diserahkanPada;
  final String? diserahkanOleh;
  final String idPelapor;
  final String namaPelapor;
  final DateTime createdAt;
  final DateTime diperbaruiPada;

  const ItemModel({
    required this.id,
    required this.tipe,
    required this.nama,
    required this.kategori,
    required this.fakultas,
    required this.tanggalKejadian,
    required this.catatanTambahan,
    this.fotoUrl,
    this.idPos,
    this.namaPos,
    required this.status,
    this.diserahkanKepada,
    this.diserahkanPada,
    this.diserahkanOleh,
    required this.idPelapor,
    required this.namaPelapor,
    required this.createdAt,
    required this.diperbaruiPada,
  });

  bool get isHilang => tipe == AppConst.tipeHilang;
  bool get isDitemukan => tipe == AppConst.tipeDitemukan;
  bool get isSelesai => status == AppConst.statusSelesai;

  /// Teks untuk chip status: Hilang / Di pos / Selesai
  String get statusLabel {
    if (isSelesai) return 'Selesai';
    return isHilang ? 'Hilang' : 'Di pos';
  }

  /// Barang di pos yang sudah > 14 hari tanpa diperbarui satpam
  bool get isLaporanLama =>
      isDitemukan &&
      !isSelesai &&
      DateTime.now().difference(diperbaruiPada).inDays >
          AppConst.batasHariLaporanLama;

  static DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory ItemModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    // createdAt bisa null sesaat setelah kirim (serverTimestamp belum terisi)
    final created = _ts(d['createdAt']) ?? DateTime.now();
    return ItemModel(
      id: doc.id,
      tipe: d['tipe'] ?? AppConst.tipeHilang,
      nama: d['nama'] ?? '',
      kategori: d['kategori'] ?? '',
      fakultas: d['fakultas'] ?? '',
      tanggalKejadian: _ts(d['tanggalKejadian']) ?? created,
      catatanTambahan: d['catatanTambahan'] ?? '',
      fotoUrl: d['fotoUrl'],
      idPos: d['idPos'],
      namaPos: d['namaPos'],
      status: d['status'] ?? AppConst.statusAktif,
      diserahkanKepada: d['diserahkanKepada'],
      diserahkanPada: _ts(d['diserahkanPada']),
      diserahkanOleh: d['diserahkanOleh'],
      idPelapor: d['idPelapor'] ?? '',
      namaPelapor: d['namaPelapor'] ?? '',
      createdAt: created,
      diperbaruiPada: _ts(d['diperbaruiPada']) ?? created,
    );
  }
}
