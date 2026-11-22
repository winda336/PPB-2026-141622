import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'report_form.dart';

/// Halaman tab "Tambah Laporan": pilih Hilang / Ditemukan, lalu isi form.
class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key, this.onSubmitted});
  final VoidCallback? onSubmitted;

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  String _tipe = AppConst.tipeHilang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lapor barang')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: AppConst.tipeHilang, label: Text('Hilang')),
                  ButtonSegment(
                      value: AppConst.tipeDitemukan, label: Text('Ditemukan')),
                ],
                selected: {_tipe},
                onSelectionChanged: (s) => setState(() => _tipe = s.first),
              ),
            ),
          ),
          Expanded(
            // key membuat form direset saat berpindah Hilang <-> Ditemukan
            child: ReportForm(
              key: ValueKey(_tipe),
              tipe: _tipe,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
