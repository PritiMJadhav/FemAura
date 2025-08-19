import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Bumpbook extends StatefulWidget {
  @override
  _BumpbookState createState() => _BumpbookState();
}

class _BumpbookState extends State<Bumpbook> {
  final List<Map<String, dynamic>> _entries = [];
  final TextEditingController _noteController = TextEditingController();
  File? _selectedImage;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  int? _expandedIndex; // 🔹 Track which card is expanded

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addEntry() {
    if (_noteController.text.isEmpty && _selectedImage == null) return;

    final now = DateTime.now();
    final date = "${now.day}-${now.month}-${now.year}";
    final weekday = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][now.weekday % 7];

    final entry = {
      "date": date,
      "day": weekday,
      "note": _noteController.text,
      "image": _selectedImage,
    };

    setState(() {
      _entries.insert(0, entry);
      _listKey.currentState?.insertItem(0); // Animate add
      _noteController.clear();
      _selectedImage = null;
    });
  }

  void _deleteEntry(int index) {
    final removed = _entries.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildEntryCard(removed, index, animation, true),
      duration: Duration(milliseconds: 400),
    );
  }

  void _confirmDeleteEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.pink.shade400, size: 50),
              SizedBox(height: 12),
              Text(
                "Delete Entry?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700),
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to delete this memory?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _deleteEntry(index);
                      Navigator.pop(context);
                    },
                    child: Text("Delete"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry, int index,
      Animation<double> animation, bool isRemoving) {
    final isExpanded = _expandedIndex == index;

    final card = GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade100],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${entry['day']}, ${entry['date']}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),

            // Show short note if collapsed, full if expanded
            if (entry['note'] != null && entry['note'].isNotEmpty)
              Text(
                isExpanded && entry['note'].length > 100
                    ? entry['note']
                    : entry['note'].length > 100
                        ? entry['note'].substring(0, 100) + "..."
                        : entry['note'],
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),

            if (entry['image'] != null) ...[
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  entry['image'],
                  height: isExpanded ? 250 : 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            if (isExpanded) ...[
              SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                  onPressed: () => _confirmDeleteEntry(index),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );

    return isRemoving
        ? SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(opacity: animation, child: card),
          )
        : SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.2, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: animation, child: card),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text("Baby Bump Diary"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade300,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          // Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.09,
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/Baby_Bump.png",
                  width: 280,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: "Write your diary entry...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.pink.shade50,
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.image,
                                        color: Colors.grey.shade600),
                                  ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.upload_file, color: Colors.white),
                              label: Text("Upload",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                backgroundColor: Colors.pink.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: _addEntry,
                              child: Text("Add Entry",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 12),
                                backgroundColor: Colors.pink.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: _entries.isEmpty
                    ? Center(
                        child: Text(
                          "No diary entries yet 🌸",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic),
                        ),
                      )
                    : AnimatedList(
                        key: _listKey,
                        initialItemCount: _entries.length,
                        itemBuilder: (context, index, animation) {
                          return _buildEntryCard(
                              _entries[index], index, animation, false);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
