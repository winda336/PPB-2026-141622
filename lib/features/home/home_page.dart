import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/item_repository.dart';
import '../../widgets/item_card.dart';
import '../../widgets/state_views.dart';
import '../detail/item_detail_page.dart';

/// Beranda: daftar laporan hilang & ditemukan dari Firestore.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.repository});
  final ItemRepository? repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Stream<List<ItemModel>> _stream =
      (widget.repository ?? ItemRepository()).watchItems();

  String _jenis = 'semua'; // semua / hilang / ditemukan
  String _query = '';

  List<ItemModel> _filter(List<ItemModel> all) {
    return all.where((i) {
      if (i.isSelesai) return false; // yang selesai tidak tampil di beranda
      if (i.isLaporanLama) return false; // > 14 hari disembunyikan
      if (_jenis != 'semua' && i.tipe != _jenis) return false;
      if (_query.isNotEmpty &&
          !i.nama.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama barang...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final e in const {
                  'semua': 'Semua',
                  'hilang': 'Hilang',
                  'ditemukan': 'Ditemukan',
                }.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: _jenis == e.key,
                    onSelected: (_) => setState(() => _jenis = e.key),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) return ErrorView(error: snap.error!);
                if (!snap.hasData) return const LoadingView();
                final items = _filter(snap.data!);
                if (items.isEmpty) {
                  return const EmptyView(
                      message: 'Belum ada laporan yang cocok.');
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => ItemCard(
                    item: items[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ItemDetailPage(item: items[i])),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}