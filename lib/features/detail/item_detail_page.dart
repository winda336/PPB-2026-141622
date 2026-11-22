import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/utils.dart';
import '../../models/item_model.dart';
import '../../widgets/status_chip.dart';

/// Detail barang. Tidak ada tombol klaim / hubungi:
/// verifikasi dilakukan satpam di pos.
class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key, required this.item});
  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final lokasiLabel = item.isDitemukan ? 'Ditemukan di' : 'Hilang di';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail barang')),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            child: item.fotoUrl != null
                ? Image.network(item.fotoUrl!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          size: 64, color: Colors.grey),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.nama,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                    ),
                    StatusChip(item: item),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                    '$lokasiLabel ${item.fakultas} | ${formatTanggal(item.tanggalKejadian)}'),
                Text('Kategori: ${item.kategori}'),
                Text('Dilaporkan oleh ${item.namaPelapor}'),
                const SizedBox(height: 16),
                if (item.isDitemukan && !item.isSelesai)
                  _InfoBox(
                    color: AppTheme.primary,
                    icon: Icons.place_outlined,
                    title: 'Ambil di ${item.namaPos ?? '-'}',
                    body:
                        'Bawa identitas untuk diverifikasi satpam saat mengambil.',
                  ),
                if (item.isSelesai)
                  _InfoBox(
                    color: AppTheme.selesai,
                    icon: Icons.check_circle_outline,
                    title: 'Sudah diserahkan',
                    body: 'Diserahkan kepada ${item.diserahkanKepada ?? '-'}'
                        '${item.diserahkanPada != null ? ' pada ${formatTanggal(item.diserahkanPada!)}' : ''}.',
                  ),
                const SizedBox(height: 16),
                const Text('Catatan tambahan (detail lokasi)',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.catatanTambahan.isEmpty ? '-' : item.catatanTambahan),
                const SizedBox(height: 24),
                Text(
                  'Tidak ada proses klaim di aplikasi. '
                  'Verifikasi dilakukan satpam di pos.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox(
      {required this.color,
      required this.icon,
      required this.title,
      required this.body});
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 2),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      );
}