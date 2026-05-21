import '../models/wisata_model.dart';

class DummyData {
  static final Wisata wisata = Wisata(
    id: 1,
    nama: 'Candi Prambanan',
    images: [
      WisataImage(
        id: 1,
        imageName: 'assets/images/prambanan1.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WisataImage(
        id: 2,
        imageName: 'assets/images/prambanan2.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    lokasi: 'Sleman, Daerah Istimewa Yogyakarta',
    longitude: 110.4910,
    latitude: -7.7520,
    deskripsi:
        'Candi Prambanan adalah kompleks candi Hindu terbesar di Indonesia. '
        'Candi ini dibangun pada abad ke-9 dan merupakan salah satu keajaiban '
        'arsitektur dunia yang telah diakui oleh UNESCO sebagai Warisan Budaya Dunia.',
    sejarah:
        'Dibangun sekitar tahun 850 Masehi oleh Rakai Pikatan dari Dinasti Sanjaya, '
        'Candi Prambanan didedikasikan untuk Trimurti — tiga dewa utama Hindu yaitu '
        'Brahma, Wisnu, dan Siwa. Kompleks ini sempat ditinggalkan dan runtuh akibat '
        'gempa bumi, namun kemudian dipugar secara bertahap oleh pemerintah.',
    audioSejarah: 'audio/prambanan.mp3',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
