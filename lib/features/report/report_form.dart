import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/pos_model.dart';
import '../../services/report_service.dart';

/// Form laporan.
///   tipe = hilang     -> form barang hilang (adegan 3)
///   tipe = ditemukan  -> form barang ditemukan (adegan 5), ada pilihan pos
class ReportForm extends StatefulWidget {
  const ReportForm(
      {super.key, required this.tipe, this.onSubmitted, this.service});
  final String tipe;
  final VoidCallback? onSubmitted;
  final ReportService? service;

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _catatanC = TextEditingController();
  late final ReportService _service = widget.service ?? ReportService();

  String? _kategori;
  String? _fakultas;
  PosModel? _pos;
  DateTime _tanggal = DateTime.now();
  bool _saving = false;

  bool get _ditemukan => widget.tipe == AppConst.tipeDitemukan;

  @override
  void dispose() {
    _namaC.dispose();
    _catatanC.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _tanggal = d);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Kamu harus login dulu.');
      return;
    }
    setState(() => _saving = true);
    try {
      final nama = await _service.getNamaPelapor(user.uid,
          fallback: user.displayName ?? user.email ?? 'Pengguna');
      await _service.submit(ReportInput(
        tipe: widget.tipe,
        nama: _namaC.text,
        kategori: _kategori!,
        fakultas: _fakultas!,
        tanggalKejadian: _tanggal,
        catatanTambahan: _catatanC.text,
        pos: _pos,
        idPelapor: user.uid,
        namaPelapor: nama,
      ));
      if (!mounted) return;
      _snack('Laporan berhasil dikirim.');
      _formKey.currentState!.reset();
      _namaC.clear();
      _catatanC.clear();
      setState(() {
        _kategori = null;
        _fakultas = null;
        _pos = null;
        _tanggal = DateTime.now();
      });
      widget.onSubmitted?.call();
    } catch (e) {
      if (mounted) _snack('Gagal mengirim laporan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _wajib(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _namaC,
            decoration: const InputDecoration(labelText: 'Nama barang'),
            validator: _wajib,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _kategori,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: [
              for (final k in AppConst.kategori)
                DropdownMenuItem(value: k, child: Text(k)),
            ],
            onChanged: (v) => setState(() => _kategori = v),
            validator: (v) => v == null ? 'Pilih kategori' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _fakultas,
            decoration: InputDecoration(
                labelText: _ditemukan ? 'Lokasi ditemukan' : 'Lokasi hilang'),
            items: [
              for (final f in AppConst.fakultas)
                DropdownMenuItem(value: f, child: Text(f)),
            ],
            onChanged: (v) => setState(() {
              _fakultas = v;
              _pos = null; // pos tergantung fakultas
            }),
            validator: (v) => v == null ? 'Pilih fakultas' : null,
          ),
          if (_ditemukan) ...[
            const SizedBox(height: 14),
            _buildPosDropdown(),
          ],
          const SizedBox(height: 14),
          InkWell(
            onTap: _pilihTanggal,
            child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Tanggal kejadian',
                  suffixIcon: Icon(Icons.calendar_today_outlined)),
              child: Text(formatTanggal(_tanggal)),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _catatanC,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Catatan tambahan (detail lokasi)',
                alignLabelWithHint: true),
          ),
          if (_ditemukan) ...[
            const SizedBox(height: 12),
            Text(
              'Pastikan barang sudah kamu serahkan ke pos sebelum mengirim laporan.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Kirim laporan'),
          ),
        ],
      ),
    );
  }

  Widget _buildPosDropdown() {
    if (_fakultas == null) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Dititipkan di'),
        child:
            Text('Pilih fakultas dulu', style: TextStyle(color: Colors.grey)),
      );
    }
    return StreamBuilder<List<PosModel>>(
      stream: _service.watchPos(_fakultas!),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (snap.hasData && list.isEmpty) {
          return const InputDecorator(
            decoration: InputDecoration(labelText: 'Dititipkan di'),
            child: Text('Belum ada pos untuk fakultas ini',
                style: TextStyle(color: Colors.red)),
          );
        }
        return DropdownButtonFormField<PosModel>(
          value: _pos,
          decoration: const InputDecoration(labelText: 'Dititipkan di'),
          items: [
            for (final p in list)
              DropdownMenuItem(value: p, child: Text(p.nama)),
          ],
          onChanged: (v) => setState(() => _pos = v),
          validator: (v) => v == null ? 'Pilih pos satpam' : null,
        );
      },
    );
  }
}
