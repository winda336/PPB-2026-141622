import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';

/// Membaca koleksi `items` (hanya baca, tidak menulis).
class ItemRepository {
  ItemRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  /// Semua laporan, terbaru di atas. Penyaringan dilakukan di sisi aplikasi
  /// supaya tidak perlu membuat composite index di Firestore.
  Stream<List<ItemModel>> watchItems() {
    return _db
        .collection('items')
        .orderBy('diperbaruiPada', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ItemModel.fromDoc).toList());
  }
}