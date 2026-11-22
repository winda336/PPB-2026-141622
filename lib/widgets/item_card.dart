import 'package:flutter/material.dart';
import '../core/utils.dart';
import '../models/item_model.dart';
import 'status_chip.dart';

/// Kartu satu laporan di daftar Beranda.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, required this.onTap});
  final ItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String line1 = item.isDitemukan
        ? '${item.fakultas}, ${item.catatanTambahan}'
        : 'Hilang di ${item.fakultas}';
    final String line2 = item.isDitemukan
        ? 'Di ${item.namaPos ?? '-'}'
        : 'Dilaporkan ${waktuRelatif(item.createdAt)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.fotoUrl != null
                      ? Image.network(item.fotoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_outlined,
                              color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(item.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        const SizedBox(width: 8),
                        StatusChip(item: item),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(line1, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(line2,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}