import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:nusantara_trail/utils/wisata_service.dart';
import '../models/wisata_model.dart';

class DetailScreen extends StatefulWidget {
  final int wisataId;
  const DetailScreen({required this.wisataId, super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Wisata? _wisata;
  late final AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentImageIndex = 0;
  bool _showFullSejarah = false;
  bool _showFullDeskripsi = false;

  // Review state
  int _reviewRating = 0;
  final _reviewController = TextEditingController();
  bool _reviewSubmitted = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _fetchWisata();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _fetchWisata() async {
    try {
      final wisata = await WisataService.getWisataById(widget.wisataId);
      if (mounted) setState(() => _wisata = wisata);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        print('Audio URL: ${_wisata!.audioSejarah}');
        final audioUrl = 'http://192.168.1.10:3000${_wisata!.audioSejarah}';
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _submitReview() {
    if (_reviewRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih rating terlebih dahulu'),
          backgroundColor: const Color(0xFFC0392B),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tulis ulasan terlebih dahulu'),
          backgroundColor: const Color(0xFFC0392B),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _reviewSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ulasan berhasil dikirim, terima kasih!'),
        backgroundColor: const Color(0xFF4A7C2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_wisata == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2D5016),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4A853),
            strokeWidth: 2.5,
          ),
        ),
      );
    }
    final wisata = _wisata!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(wisata),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(wisata),
                const SizedBox(height: 16),
                _buildAudioPlayer(wisata),
                const SizedBox(height: 20),
                if (wisata.images.length > 1) _buildImageGallery(wisata),
                _buildDeskripsiSection(wisata),
                _buildSejarahSection(wisata),
                _buildLokasiSection(wisata),
                const SizedBox(height: 20),
                _buildReviewSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Wisata wisata) {
    final imageUrl = wisata.images.isNotEmpty
        ? 'http://192.168.1.10:3000${wisata.images[_currentImageIndex].imageName}'
        : null;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF2D5016),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2D5016),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white54, size: 48),
                ),
              )
            else
              Container(color: const Color(0xFF2D5016)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            if (wisata.images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: wisata.images.asMap().entries.map((e) {
                    return Container(
                      width: _currentImageIndex == e.key ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _currentImageIndex == e.key
                            ? const Color(0xFFD4A853)
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(Wisata wisata) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wisata.nama,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E0A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.place_rounded,
                  size: 16, color: Color(0xFFD4A853)),
              const SizedBox(width: 4),
              Text(
                wisata.lokasi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7C61),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(Wisata wisata) {
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D5016), Color(0xFF4A7C2F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5016).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.headphones_rounded,
                    color: Color(0xFFD4A853), size: 20),
                SizedBox(width: 8),
                Text(
                  'Panduan Audio Sejarah',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Dengarkan kisah sejarah lokasi ini',
              style: TextStyle(color: Color(0xFFB8C9A0), fontSize: 12),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFD4A853),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFFD4A853),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
                trackHeight: 3,
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (v) {
                  final pos = Duration(
                      milliseconds: (v * _duration.inMilliseconds).round());
                  _audioPlayer.seek(pos);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final newPos = _position - const Duration(seconds: 10);
                    _audioPlayer
                        .seek(newPos < Duration.zero ? Duration.zero : newPos);
                  },
                  icon: const Icon(Icons.replay_10_rounded,
                      color: Colors.white70, size: 28),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD4A853),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    final newPos = _position + const Duration(seconds: 10);
                    _audioPlayer.seek(newPos > _duration ? _duration : newPos);
                  },
                  icon: const Icon(Icons.forward_10_rounded,
                      color: Colors.white70, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(Wisata wisata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            'Galeri Foto',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E0A),
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: wisata.images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final imgUrl = wisata.images[i].imageName;
              return GestureDetector(
                onTap: () => setState(() => _currentImageIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _currentImageIndex == i
                          ? const Color(0xFFD4A853)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8E0CC),
                        child: const Icon(Icons.image,
                            color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDeskripsiSection(Wisata wisata) {
    const maxLines = 4;
    final isLong = wisata.deskripsi.split('\n').length > maxLines ||
        wisata.deskripsi.length > 300;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E0A),
            ),
          ),
          const SizedBox(height: 10),
          // Selalu full width, tinggi mengikuti konten
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wisata.deskripsi,
                  maxLines: _showFullDeskripsi ? null : maxLines,
                  overflow: _showFullDeskripsi
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5C3A),
                    height: 1.6,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(
                        () => _showFullDeskripsi = !_showFullDeskripsi),
                    child: Text(
                      _showFullDeskripsi
                          ? 'Tampilkan lebih sedikit'
                          : 'Baca selengkapnya',
                      style: const TextStyle(
                        color: Color(0xFF4A7C2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSejarahSection(Wisata wisata) {
    const maxLines = 5;
    final isLong = wisata.sejarah.split('\n').length > maxLines ||
        wisata.sejarah.length > 400;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sejarah',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E0A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5016).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Warisan Budaya',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2D5016),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Selalu full width, tinggi mengikuti konten
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: const Border(
                left: BorderSide(color: Color(0xFFD4A853), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wisata.sejarah,
                  maxLines: _showFullSejarah ? null : maxLines,
                  overflow: _showFullSejarah
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5C3A),
                    height: 1.7,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showFullSejarah = !_showFullSejarah),
                    child: Text(
                      _showFullSejarah
                          ? 'Tampilkan lebih sedikit'
                          : 'Baca selengkapnya',
                      style: const TextStyle(
                        color: Color(0xFF4A7C2F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiSection(Wisata wisata) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E0A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // Pakai Column biar alamat bisa overflow ke bawah
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5016).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.place_rounded,
                          color: Color(0xFF2D5016), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Alamat bisa wrap ke bawah sebanyak yang diperlukan
                          Text(
                            wisata.lokasi,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1A2E0A),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${wisata.latitude.toStringAsFixed(4)}, ${wisata.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A9A7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ulasan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E0A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Bagikan Pengalamanmu',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB8860B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                _reviewSubmitted ? _buildReviewSuccess() : _buildReviewForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSuccess() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4A7C2F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4A7C2F),
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Terima Kasih!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2E0A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ulasan kamu sudah berhasil dikirim.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7C61)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Tampilkan bintang yang dipilih
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return Icon(
              i < _reviewRating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: const Color(0xFFD4A853),
              size: 24,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E0A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _reviewRating = star),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  star <= _reviewRating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: star <= _reviewRating
                      ? const Color(0xFFD4A853)
                      : const Color(0xFFCCCCCC),
                  size: 36,
                ),
              ),
            );
          }),
        ),
        if (_reviewRating > 0) ...[
          const SizedBox(height: 4),
          Text(
            [
              '',
              'Sangat Buruk',
              'Buruk',
              'Cukup',
              'Bagus',
              'Luar Biasa'
            ][_reviewRating],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFB8860B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'Ulasan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E0A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewController,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E0A)),
          decoration: InputDecoration(
            hintText: 'Ceritakan pengalamanmu di sini...',
            hintStyle: const TextStyle(color: Color(0xFFADB8A3), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F0E8),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE5D4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDE5D4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF4A7C2F), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5016),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Kirim Ulasan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
