import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'pengguna_home_page.dart';
import 'satpam_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingPage();
        }

        if (authSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat sesi.')),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey(user.uid),
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingPage();
            }

            if (profileSnapshot.hasError) {
              return const _ProfileIssue(
                message:
                    'Gagal membaca profil. Periksa koneksi '
                    'internet dan Firestore Security Rules.',
              );
            }

            final data = profileSnapshot.data?.data();

            if (data == null) {
              return const _ProfileIssue(
                message:
                    'Profil belum tersedia. Jika baru '
                    'mendaftar, periksa apakah data '
                    'berhasil tersimpan.',
              );
            }

            if (data['role'] == 'satpam') {
              final idPos = data['idPos'];

              if (idPos is String && idPos.isNotEmpty) {
                return SatpamDashboardPage(idPos: idPos);
              }

              return const _ProfileIssue(
                message: 'Akun satpam belum terhubung ke pos.',
              );
            }

            if (data['role'] == 'pengguna') {
              return const PenggunaHomePage();
            }

            return const _ProfileIssue(message: 'Role akun tidak dikenal.');
          },
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ProfileIssue extends StatelessWidget {
  const _ProfileIssue({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masalah profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => AuthService().logout(),
                child: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
