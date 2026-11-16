import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class PenggunaHomePage extends StatelessWidget {
  const PenggunaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Login sebagai pengguna berhasil.\n\n'
            'Halaman ini sementara. '
            'Nantinya diganti dengan Beranda '
            'yang dibuat anggota tim.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
