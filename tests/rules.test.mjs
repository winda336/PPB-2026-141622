
import {
  before,
  beforeEach,
  after,
  test,
} from 'node:test';

import fs from 'node:fs';
import assert from 'node:assert/strict';

import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';

import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  Timestamp,
} from 'firebase/firestore';

let env;

const uidUser = 'u_budi';
const uidSatpamFKIP = 'u_satpam_fkip';
const uidSatpamFT = 'u_satpam_ft';

const satuHariLalu = () =>
  Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000),
  );

function temuan() {
  return {
    tipe: 'ditemukan',
    nama: 'KTM',
    kategori: 'Identitas',
    fakultas: 'FKIP',
    tanggalKejadian: satuHariLalu(),
    catatanTambahan: 'Area FKIP',
    fotoUrl: '',
    idPos: 'pos_fkip',
    namaPos: 'Pos Satpam FKIP',
    status: 'aktif',
    idPelapor: uidUser,
    namaPelapor: 'Budi',
    createdAt: satuHariLalu(),
    diperbaruiPada: satuHariLalu(),
  };
}

function hilang() {
  const data = temuan();

  delete data.idPos;
  delete data.namaPos;

  data.tipe = 'hilang';
  data.nama = 'Dompet';

  return data;
}

function loginSebagai(uid, email) {
  return env.authenticatedContext(
    uid,
    { email },
  ).firestore();
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-campus-lost-found',
    firestore: {
      rules: fs.readFileSync(
        'firestore.rules',
        'utf8',
      ),
    },
  });
});

beforeEach(async () => {
  await env.clearFirestore();

  await env.withSecurityRulesDisabled(
    async (context) => {
      const db = context.firestore();

      await Promise.all([
        setDoc(doc(db, 'users', uidUser), {
          nama: 'Budi',
          email: 'budi@student.uns.ac.id',
          role: 'pengguna',
          createdAt: satuHariLalu(),
        }),

        setDoc(
          doc(db, 'users', uidSatpamFKIP),
          {
            nama: 'Pak Joko',
            email: 'joko@example.com',
            role: 'satpam',
            idPos: 'pos_fkip',
            createdAt: satuHariLalu(),
          },
        ),

        setDoc(
          doc(db, 'users', uidSatpamFT),
          {
            nama: 'Bu Sari',
            email: 'sari@example.com',
            role: 'satpam',
            idPos: 'pos_ft',
            createdAt: satuHariLalu(),
          },
        ),

        setDoc(doc(db, 'pos', 'pos_fkip'), {
          nama: 'Pos Satpam FKIP',
          fakultas: 'FKIP',
        }),

        setDoc(doc(db, 'pos', 'pos_ft'), {
          nama: 'Pos Satpam FT',
          fakultas: 'FT',
        }),

        setDoc(
          doc(db, 'items', 'ktm_fkip'),
          temuan(),
        ),

        setDoc(
          doc(db, 'items', 'dompet_hilang'),
          hilang(),
        ),
      ]);
    },
  );
});

after(async () => {
  if (env) await env.cleanup();
});

test('akun belum login tidak bisa baca item', async () => {
  const db = env.unauthenticatedContext().firestore();

  await assertFails(
    getDoc(doc(db, 'items', 'ktm_fkip')),
  );
});

test('pengguna tidak bisa mendaftar sebagai satpam', async () => {
  const db = loginSebagai(
    'u_baru',
    'baru@student.uns.ac.id',
  );

  const ref = doc(db, 'users', 'u_baru');

  await assertFails(
    setDoc(ref, {
      nama: 'Mahasiswa Baru',
      email: 'baru@student.uns.ac.id',
      role: 'satpam',
      idPos: 'pos_fkip',
      createdAt: serverTimestamp(),
    }),
  );

  await assertSucceeds(
    setDoc(ref, {
      nama: 'Mahasiswa Baru',
      email: 'baru@student.uns.ac.id',
      role: 'pengguna',
      createdAt: serverTimestamp(),
    }),
  );
});

test('pengguna tidak bisa menaikkan role', async () => {
  const db = loginSebagai(
    uidUser,
    'budi@student.uns.ac.id',
  );

  await assertFails(
    updateDoc(
      doc(db, 'users', uidUser),
      {
        role: 'satpam',
        idPos: 'pos_fkip',
      },
    ),
  );
});

test('penemu tidak bisa mengedit temuan', async () => {
  const db = loginSebagai(
    uidUser,
    'budi@student.uns.ac.id',
  );

  await assertFails(
    updateDoc(
      doc(db, 'items', 'ktm_fkip'),
      {
        nama: 'KTM diubah',
        diperbaruiPada: serverTimestamp(),
      },
    ),
  );
});

test('satpam pos yang sama bisa edit dan serahkan', async () => {
  const db = loginSebagai(
    uidSatpamFKIP,
    'joko@example.com',
  );

  const ref = doc(db, 'items', 'ktm_fkip');

  await assertSucceeds(
    updateDoc(ref, {
      catatanTambahan: 'Area perpustakaan',
      diperbaruiPada: serverTimestamp(),
    }),
  );

  await assertSucceeds(
    updateDoc(ref, {
      status: 'selesai',
      diserahkanKepada: 'Rina Rahmawati',
      diserahkanPada: serverTimestamp(),
      diserahkanOleh: uidSatpamFKIP,
      diperbaruiPada: serverTimestamp(),
    }),
  );

  const snapshot = await getDoc(ref);

  assert.equal(
    snapshot.data().status,
    'selesai',
  );

  // Laporan selesai tidak boleh dihapus.
  await assertFails(deleteDoc(ref));
});

test('satpam pos lain ditolak', async () => {
  const db = loginSebagai(
    uidSatpamFT,
    'sari@example.com',
  );

  const ref = doc(db, 'items', 'ktm_fkip');

  await assertFails(
    updateDoc(ref, {
      nama: 'Nama palsu',
      diperbaruiPada: serverTimestamp(),
    }),
  );

  await assertFails(
    updateDoc(ref, {
      status: 'selesai',
      diserahkanKepada: 'Rina',
      diserahkanPada: serverTimestamp(),
      diserahkanOleh: uidSatpamFT,
      diperbaruiPada: serverTimestamp(),
    }),
  );

  await assertFails(deleteDoc(ref));
});

test('satpam tidak bisa memindah pos', async () => {
  const db = loginSebagai(
    uidSatpamFKIP,
    'joko@example.com',
  );

  await assertFails(
    updateDoc(
      doc(db, 'items', 'ktm_fkip'),
      {
        idPos: 'pos_ft',
        diperbaruiPada: serverTimestamp(),
      },
    ),
  );
});

test('pengguna bisa mengubah laporan hilang sendiri', async () => {
  const db = loginSebagai(
    uidUser,
    'budi@student.uns.ac.id',
  );

  await assertSucceeds(
    updateDoc(
      doc(db, 'items', 'dompet_hilang'),
      {
        status: 'selesai',
        diperbaruiPada: serverTimestamp(),
      },
    ),
  );

  const dbLain = loginSebagai(
    'u_lain',
    'lain@student.uns.ac.id',
  );

  await assertFails(
    updateDoc(
      doc(dbLain, 'items', 'dompet_hilang'),
      {
        nama: 'Dompet palsu',
        diperbaruiPada: serverTimestamp(),
      },
    ),
  );
});

test('pengguna bisa membuat laporan temuan valid', async () => {
  const db = loginSebagai(
    uidUser,
    'budi@student.uns.ac.id',
  );

  await assertSucceeds(
    setDoc(
      doc(db, 'items', 'payung_baru'),
      {
        tipe: 'ditemukan',
        nama: 'Payung biru',
        kategori: 'Lainnya',
        fakultas: 'FKIP',
        tanggalKejadian: satuHariLalu(),
        catatanTambahan: 'Parkiran',
        fotoUrl: '',
        idPos: 'pos_fkip',
        namaPos: 'Pos Satpam FKIP',
        status: 'aktif',
        idPelapor: uidUser,
        namaPelapor: 'Budi',
        createdAt: serverTimestamp(),
        diperbaruiPada: serverTimestamp(),
      },
    ),
  );
});

test('data master pos tidak bisa diubah klien', async () => {
  const db = loginSebagai(
    uidSatpamFKIP,
    'joko@example.com',
  );

  await assertFails(
    updateDoc(
      doc(db, 'pos', 'pos_fkip'),
      {
        nama: 'Pos palsu',
      },
    ),
  );
});
