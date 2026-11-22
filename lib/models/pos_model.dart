import 'package:cloud_firestore/cloud_firestore.dart';

class PosModel {
  final String id;
  final String nama;
  final String fakultas;
  final String? jamBuka;

  const PosModel({
    required this.id,
    required this.nama,
    required this.fakultas,
    this.jamBuka,
  });

  factory PosModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return PosModel(
      id: doc.id,
      nama: d['nama'] ?? '',
      fakultas: d['fakultas'] ?? '',
      jamBuka: d['jamBuka'],
    );
  }

  // supaya Dropdown bisa membandingkan pilihan
  @override
  bool operator ==(Object other) => other is PosModel && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
