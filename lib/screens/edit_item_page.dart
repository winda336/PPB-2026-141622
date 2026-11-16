import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/items_repository.dart';

class EditItemPage extends StatefulWidget {
  const EditItemPage({super.key, required this.itemId, required this.data});

  final String itemId;
  final Map<String, dynamic> data;

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _kategori;
  late final TextEditingController _fakultas;
  late final TextEditingController _catatan;

  late DateTime _tanggal;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _nama = TextEditingController(text: widget.data['nama'] as String? ?? '');

    _kategori = TextEditingController(
      text: widget.data['kategori'] as String? ?? '',
    );

    _fakultas = TextEditingController(
      text: widget.data['fakultas'] as String? ?? '',
    );

    _catatan = TextEditingController(
      text: widget.data['catatanTambahan'] as String? ?? '',
    );

    final timestamp = widget.data['tanggalKejadian'];

    _tanggal = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
  }

  @override
  void dispose() {
    _nama.dispose();
    _kategori.dispose();
    _fakultas.dispose();
    _catatan.dispose();

    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final tanggalAwal = _tanggal.isAfter(DateTime.now())
        ? DateTime.now()
        : _tanggal;

    final pilihan = await showDatePicker(
      context: context,
      initialDate: tanggalAwal,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pilihan != null) {
      setState(() => _tanggal = pilihan);
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      await ItemsRepository().editTemuan(
        itemId: widget.itemId,
        nama: _nama.text,
        kategori: _kategori.text,
        fakultas: _fakultas.text,
        catatanTambahan: _catatan.text,
        tanggalKejadian: _tanggal,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit laporan temuan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pos: '
                '${widget.data['namaPos'] ?? widget.data['idPos']}',
              ),

              const SizedBox(height: 16),

              _input(
                _nama,
                'Nama barang',
                validator: (value) {
                  final length = value?.trim().length ?? 0;

                  if (length < 2 || length > 120) {
                    return 'Isi 2-120 karakter.';
                  }

                  return null;
                },
              ),

              _input(
                _kategori,
                'Kategori',
                validator: (value) {
                  final length = value?.trim().length ?? 0;

                  if (length < 1 || length > 80) {
                    return 'Isi 1-80 karakter.';
                  }

                  return null;
                },
              ),

              _input(
                _fakultas,
                'Fakultas',
                validator: (value) {
                  final length = value?.trim().length ?? 0;

                  if (length < 1 || length > 80) {
                    return 'Isi 1-80 karakter.';
                  }

                  return null;
                },
              ),

              _input(
                _catatan,
                'Catatan tambahan',
                maxLines: 3,
                validator: (value) {
                  if ((value?.length ?? 0) > 1000) {
                    return 'Maksimal 1000 karakter.';
                  }

                  return null;
                },
              ),

              OutlinedButton.icon(
                onPressed: _loading ? null : _pilihTanggal,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Tanggal kejadian: '
                  '${_tanggal.day}/'
                  '${_tanggal.month}/'
                  '${_tanggal.year}',
                ),
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: _loading ? null : _simpan,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
