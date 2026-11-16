import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/items_repository.dart';
import 'edit_item_page.dart';

class SatpamDashboardPage extends StatefulWidget {
  const SatpamDashboardPage({super.key, required this.idPos});

  final String idPos;

  @override
  State<SatpamDashboardPage> createState() => _SatpamDashboardPageState();
}

class _SatpamDashboardPageState extends State<SatpamDashboardPage> {
  final _repo = ItemsRepository();

  void _showError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Operasi gagal: $error')));
  }

  // Dialog penyerahan barang.
  Future<void> _serahkan(String itemId, String namaBarang) async {
    final penerima = TextEditingController();

    bool identitasDiperiksa = false;
    bool menyimpan = false;
    bool berhasil = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Serahkan ke Pemilik'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Barang: $namaBarang'),

                      const SizedBox(height: 12),

                      TextField(
                        controller: penerima,
                        enabled: !menyimpan,
                        maxLength: 120,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (_) {
                          setDialogState(() {});
                        },
                        decoration: const InputDecoration(
                          labelText: 'Nama penerima',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: identitasDiperiksa,
                        onChanged: menyimpan
                            ? null
                            : (value) {
                                setDialogState(() {
                                  identitasDiperiksa = value ?? false;
                                });
                              },
                        title: const Text(
                          'Identitas pemilik sudah '
                          'diverifikasi langsung di pos',
                        ),
                      ),

                      const Text(
                        'Nomor identitas tidak '
                        'disimpan dalam aplikasi.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: menyimpan
                        ? null
                        : () {
                            Navigator.pop(dialogContext);
                          },
                    child: const Text('Batal'),
                  ),

                  FilledButton(
                    onPressed:
                        menyimpan ||
                            !identitasDiperiksa ||
                            penerima.text.trim().length < 2
                        ? null
                        : () async {
                            setDialogState(() {
                              menyimpan = true;
                            });

                            try {
                              await _repo.serahkanKePemilik(
                                itemId: itemId,
                                namaPenerima: penerima.text,
                              );

                              berhasil = true;

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Penyerahan '
                                      'berhasil dicatat.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              _showError(e);
                            } finally {
                              if (!berhasil && dialogContext.mounted) {
                                setDialogState(() {
                                  menyimpan = false;
                                });
                              }
                            }
                          },
                    child: menyimpan
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan dan tutup'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      penerima.dispose();
    }
  }

  // Konfirmasi penghapusan laporan.
  Future<void> _hapus(String itemId, String namaBarang) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus laporan?'),
          content: Text(
            'Hapus laporan "$namaBarang"? '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (yakin != true) return;

    try {
      await _repo.hapusTemuan(itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan temuan dihapus.')),
        );
      }
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Titipan di Pos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('pos')
                  .doc(widget.idPos)
                  .get(),
              builder: (context, snapshot) {
                final namaPos =
                    snapshot.data?.data()?['nama'] as String? ??
                    'Pos: ${widget.idPos}';

                return Text(
                  namaPos,
                  style: Theme.of(context).textTheme.titleMedium,
                );
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _repo.titipanAktif(widget.idPos),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Gagal membaca titipan: '
                        '${snapshot.error}',
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada barang aktif '
                      'di pos ini.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final item = doc.data();

                    final nama = item['nama'] as String? ?? 'Tanpa nama';

                    final catatan = item['catatanTambahan'] as String? ?? '';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nama,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                const Chip(label: Text('Di pos')),
                              ],
                            ),

                            Text(
                              'Dititipkan oleh: '
                              '${item['namaPelapor'] ?? '-'}',
                            ),

                            Text(
                              'Fakultas: '
                              '${item['fakultas'] ?? '-'}',
                            ),

                            if (catatan.isNotEmpty) Text('Lokasi: $catatan'),

                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    _serahkan(doc.id, nama);
                                  },
                                  icon: const Icon(Icons.how_to_reg),
                                  label: const Text('Serahkan ke pemilik'),
                                ),

                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => EditItemPage(
                                          itemId: doc.id,
                                          data: item,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),

                                TextButton.icon(
                                  onPressed: () {
                                    _hapus(doc.id, nama);
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
