import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
// GANTI `campus_lost_found` dengan nama package di pubspec.yaml kalian.
import 'package:campus_lost_found/models/pos_model.dart';
import 'package:campus_lost_found/services/report_service.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ReportService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ReportService(firestore: db);
  });

  test('laporan hilang tersimpan dengan status aktif', () async {
    final id = await service.submit(ReportInput(
      tipe: 'hilang',
      nama: 'KTM',
      kategori: 'Identitas',
      fakultas: 'FKIP',
      tanggalKejadian: DateTime(2026, 11, 9),
      catatanTambahan: 'Sekitar Gedung E, KTM warna biru',
      idPelapor: 'uid-rina',
      namaPelapor: 'Rina',
    ));
    final d = (await db.collection('items').doc(id).get()).data()!;
    expect(d['tipe'], 'hilang');
    expect(d['status'], 'aktif');
    expect(d['idPos'], isNull);
    expect(d['idPelapor'], 'uid-rina');
  });

  test('laporan ditemukan menyimpan pos titipan', () async {
    final id = await service.submit(ReportInput(
      tipe: 'ditemukan',
      nama: 'KTM',
      kategori: 'Identitas',
      fakultas: 'FKIP',
      tanggalKejadian: DateTime(2026, 11, 9),
      catatanTambahan: 'Tangga lantai 2',
      pos: const PosModel(
          id: 'pos_gedung_e_fkip',
          nama: 'Pos Satpam Gedung E FKIP',
          fakultas: 'FKIP'),
      idPelapor: 'uid-budi',
      namaPelapor: 'Budi',
    ));
    final d = (await db.collection('items').doc(id).get()).data()!;
    expect(d['idPos'], 'pos_gedung_e_fkip');
    expect(d['namaPos'], 'Pos Satpam Gedung E FKIP');
  });

  test('ditemukan tanpa pos ditolak', () {
    expect(
      () => service.submit(ReportInput(
        tipe: 'ditemukan',
        nama: 'KTM',
        kategori: 'Identitas',
        fakultas: 'FKIP',
        tanggalKejadian: DateTime.now(),
        catatanTambahan: '',
        idPelapor: 'u',
        namaPelapor: 'B',
      )),
      throwsArgumentError,
    );
  });
}
