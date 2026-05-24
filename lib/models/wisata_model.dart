class WisataImage {
  final int id;
  final String imageName;
  final DateTime createdAt;
  final DateTime updatedAt;

  WisataImage({
    required this.id,
    required this.imageName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WisataImage.fromJson(Map<String, dynamic> json) {
    return WisataImage(
      id: json['id'],
      imageName: json['image_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_name': imageName,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class Wisata {
  final int id;
  final String nama;
  final List<WisataImage> images;
  final String lokasi;
  final double longitude;
  final double latitude;
  final String deskripsi;
  String sejarah;
  String audioSejarah;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wisata({
    required this.id,
    required this.nama,
    required this.images,
    required this.lokasi,
    required this.longitude,
    required this.latitude,
    required this.deskripsi,
    required this.sejarah,
    required this.audioSejarah,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wisata.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return Wisata(
      id: data['id'],
      nama: data['name'],
      images: [
        WisataImage(
          id: 0,
          imageName: data['coverImage'] ?? 'assets/images/default.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ], // karena API belum mengirim images
      lokasi: data['address'],
      longitude: double.parse(data['longitude']),
      latitude: double.parse(data['latitude']),
      deskripsi: data['description'],
      sejarah: '', // belum ada di API
      audioSejarah: '', // belum ada di API
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'images': images.map((e) => e.toJson()).toList(),
        'lokasi': lokasi,
        'longitude': longitude,
        'latitude': latitude,
        'deskripsi': deskripsi,
        'sejarah': sejarah,
        'audio_sejarah': audioSejarah,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
