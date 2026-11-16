import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  // Login untuk pengguna biasa dan satpam.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    final user = await _db.collection('users').doc(uid).get();

    final role = user.data()?['role'];

    if (role != 'pengguna' && role != 'satpam') {
      await _auth.signOut();

      throw StateError('Profil belum tersedia atau role tidak valid.');
    }

    return role as String;
  }

  // Pendaftaran mandiri hanya untuk role pengguna.
  Future<void> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    try {
      await _db.collection('users').doc(uid).set({
        'nama': nama.trim(),
        'email': credential.user!.email,
        'role': 'pengguna',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Coba bersihkan akun jika profil gagal dibuat.
      try {
        await credential.user!.delete();
      } catch (_) {
        await _auth.signOut();
      }

      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
