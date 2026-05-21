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
  final String sejarah;
  final String audioSejarah;
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
    return Wisata(
      id: json['id'],
      nama: json['nama'],
      images: (json['images'] as List<dynamic>)
          .map((e) => WisataImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      lokasi: json['lokasi'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      deskripsi: json['deskripsi'],
      sejarah: json['sejarah'],
      audioSejarah: json['audio_sejarah'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
