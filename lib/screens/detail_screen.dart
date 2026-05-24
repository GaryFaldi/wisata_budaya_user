import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/wisata_model.dart';

class DetailScreen extends StatefulWidget {
  final Wisata wisata;

  const DetailScreen({super.key, required this.wisata});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentImageIndex = 0;
  bool _showFullSejarah = false;
  bool _showFullDeskripsi = false;

  // SWAP URL — aktifkan saat pakai API
  // static const String fileBaseUrl = 'https://your-api-domain.com/storage/';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        // SWAP AUDIO SOURCE — pilih salah satu
        await _audioPlayer
            .play(AssetSource(widget.wisata.audioSejarah)); // ← DUMMY
        // final audioUrl = '$fileBaseUrl${widget.wisata.audioSejarah}';  // ← API
        // await _audioPlayer.play(UrlSource(audioUrl));                  // ← API
      }
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final wisata = widget.wisata;

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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Wisata wisata) {
    // SWAP IMAGE URL — pilih salah satu
    final imageUrl = wisata.images.isNotEmpty
        ? wisata.images[_currentImageIndex].imageName // ← DUMMY
        : null;
    // final imageUrl = wisata.images.isNotEmpty                              // ← API
    //     ? '$fileBaseUrl${wisata.images[_currentImageIndex].imageName}'     // ← API
    //     : null;                                                             // ← API

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
              // SWAP IMAGE WIDGET — pilih salah satu
              Image.asset(
                // ← DUMMY
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF2D5016),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white54, size: 48),
                ),
              )
            // Image.network(        // ← API
            //   imageUrl,
            //   fit: BoxFit.cover,
            //   errorBuilder: (_, __, ___) => Container(
            //     color: const Color(0xFF2D5016),
            //     child: const Icon(Icons.image_not_supported,
            //         color: Colors.white54, size: 48),
            //   ),
            // )
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
              // SWAP IMAGE URL — pilih salah satu
              final imgUrl = wisata.images[i].imageName; // ← DUMMY
              // final imgUrl = '$fileBaseUrl${wisata.images[i].imageName}'; // ← API
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
                    // SWAP IMAGE WIDGET — pilih salah satu
                    child: Image.asset(
                      // ← DUMMY
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8E0CC),
                        child: const Icon(Icons.image,
                            color: Colors.grey, size: 32),
                      ),
                    ),
                    // child: Image.network(  // ← API
                    //   imgUrl,
                    //   fit: BoxFit.cover,
                    //   errorBuilder: (_, __, ___) => Container(
                    //     color: const Color(0xFFE8E0CC),
                    //     child: const Icon(Icons.image,
                    //         color: Colors.grey, size: 32),
                    //   ),
                    // ),
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
          Container(
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: const Border(
                left: BorderSide(
                  color: Color(0xFFD4A853),
                  width: 4,
                ),
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
            child: Row(
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
                      Text(
                        wisata.lokasi,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A2E0A),
                        ),
                      ),
                      const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }
}
