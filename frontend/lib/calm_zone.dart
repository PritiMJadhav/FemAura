import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CalmZonePage extends StatefulWidget {
  @override
  _CalmZonePageState createState() => _CalmZonePageState();
}

class _CalmZonePageState extends State<CalmZonePage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _currentlyPlaying = '';
  bool _isPlaying = false;

  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 8))
          ..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Colors.pink.shade50,
      end: Colors.purple.shade50,
    ).animate(_animationController);

    _colorAnimation2 = ColorTween(
      begin: Colors.blue.shade50,
      end: Colors.teal.shade50,
    ).animate(_animationController);
  }

  Future<void> _playAudio(String fileName) async {
    if (_currentlyPlaying == fileName && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(AssetSource('audio/$fileName'));
      setState(() {
        _currentlyPlaying = fileName;
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildTrackCard(String title, String description, String fileName) {
    bool isPlaying = _currentlyPlaying == fileName && _isPlaying;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.pink, size: 36),
          onPressed: () => _playAudio(fileName),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation1.value ?? Colors.pink.shade50,
                _colorAnimation2.value ?? Colors.blue.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('Calm Zone', style: TextStyle(color: Colors.pink)),
                backgroundColor: Colors.white,
                bottom: TabBar(
                  labelColor: Colors.pink,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(icon: Icon(Icons.self_improvement), text: 'Meditation'),
                    Tab(icon: Icon(Icons.music_note), text: 'Calm Music'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  // Meditation Tab
                  ListView(
                    children: [
                      _buildTrackCard("Morning Mindfulness",
                          "Start your day with clarity", "meditation1.mp3"),
                      _buildTrackCard("Evening Relaxation",
                          "Wind down and relax", "meditation2.mp3"),
                    ],
                  ),
                  // Calm Music Tab
                  ListView(
                    children: [
                      _buildTrackCard("Ocean Waves",
                          "Gentle ocean sounds for deep relaxation", "music1.mp3"),
                      _buildTrackCard("Rain & Thunder",
                          "Soothing rain with distant thunder", "music2.mp3"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
