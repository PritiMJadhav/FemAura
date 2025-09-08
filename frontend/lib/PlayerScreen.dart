import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final String description;
  final String fileName; // comes from CalmZonePage
  final String image;
  final AudioPlayer audioPlayer; // ✅ added shared player

  const PlayerScreen({
    required this.title,
    required this.description,
    required this.fileName,
    required this.image,
    required this.audioPlayer,
  });

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.audioPlayer; // ✅ use the shared player

    // Listen to audio duration
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    // Listen to audio position
    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    // Start playing the file
    _playAudio();
  }

  Future<void> _playAudio() async {
    await _audioPlayer.stop(); // stop if anything is already playing
    await _audioPlayer.play(AssetSource(widget.fileName));
    setState(() => _isPlaying = true);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.resume();
      setState(() => _isPlaying = true);
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title, style: TextStyle(color: Colors.pink)),
        iconTheme: IconThemeData(color: Colors.pink),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Container(
            margin: EdgeInsets.all(24),
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(widget.image),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(color: Colors.pink.shade200, blurRadius: 12)
              ],
            ),
          ),

          // Title + description
          Text(widget.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(widget.description,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center),

          // Seek bar
          Slider(
            activeColor: Colors.pink,
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0
                ? _duration.inSeconds.toDouble()
                : 1,
            onChanged: (value) async {
              final pos = Duration(seconds: value.toInt());
              await _audioPlayer.seek(pos);
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatTime(_position)),
                Text(_formatTime(_duration)),
              ],
            ),
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, size: 40, color: Colors.pink),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  size: 64,
                  color: Colors.pink,
                ),
                onPressed: _togglePlayPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 40, color: Colors.pink),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
