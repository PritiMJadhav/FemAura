import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'PlayerScreen.dart';

class CalmZonePage extends StatefulWidget {
  @override
  _CalmZonePageState createState() => _CalmZonePageState();
}

class _CalmZonePageState extends State<CalmZonePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Shared AudioPlayer
  static final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _playAudio(String file) async {
    if (_currentlyPlaying == file) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
      });
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(file));
      setState(() {
        _currentlyPlaying = file;
      });
    }
  }

  Widget _buildTrackCard(
      String title, String subtitle, String file, String img) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(img, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(
            _currentlyPlaying == file ? Icons.pause_circle : Icons.play_circle,
            color: Colors.deepPurple,
            size: 32,
          ),
          onPressed: () => _playAudio(file),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(
                title: title,
                description: subtitle,
                fileName: file,
                image: img,
                audioPlayer: _audioPlayer, // ✅ now works
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calm Zone"),
        backgroundColor: Colors.deepPurple.shade100,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.black54,
          tabs: [
            Tab(text: "Meditation Music"),
            Tab(text: "Calm Music"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Meditation Section
          ListView(
            children: [
              _buildTrackCard(
                  "Morning Mindfulness",
                  "Start your day with clarity",
                  "audio/meditation1.mp3",
                  "assets/morning.jpg"),
              _buildTrackCard("Evening Relaxation", "Wind down and relax",
                  "audio/meditation2.mp3", "assets/evening.jpg"),
            ],
          ),
          // Calm Music Section
          ListView(
            children: [
              _buildTrackCard("Soothing Piano", "Relax with soft piano melodies",
                  "audio/calm1.mp3", "assets/music1.jpg"),
              _buildTrackCard("Ocean Waves", "Feel the calmness of the sea",
                  "audio/calm2.mp3", "assets/music2.jpg"),
            ],
          ),
        ],
      ),
    );
  }
}
