import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melody/src/controllers/audio_controller.dart';
import 'package:melody/src/helpers/common_function.dart';

class AudioList extends StatefulWidget {
  const AudioList({Key? key}) : super(key: key);

  @override
  State<AudioList> createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  final AudioController audioController = Get.put(AudioController());
  String searchQuery = ''; // To store the search query
  double offset = 0.0; // Current scroll offset
  bool isSearchBarVisible = true; // Search bar visibility flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Melody'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            _buildSongList(), // Function to build the song list
            _buildSearchBar(), // Function to build the search bar
          ],
        ),
      ),
    );
  }

  /// Handles scroll notifications to show/hide the search bar.
  bool _onScrollNotification(ScrollNotification scrollInfo) {
    // Update the offset based on scroll direction
    if (scrollInfo.metrics.axis == Axis.vertical) {
      setState(() {
        if (scrollInfo.metrics.pixels > offset) {
          // Scrolling down
          isSearchBarVisible = false;
        } else if (scrollInfo.metrics.pixels < offset) {
          // Scrolling up
          isSearchBarVisible = true;
        }
        offset = scrollInfo.metrics.pixels; // Update the offset
      });
    }
    return true;
  }

  /// Builds the list of songs based on the current search query.
  Widget _buildSongList() {
    return Obx(() {
      if (audioController.songList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      } else {
        // Filter songs based on search query
        final filteredSongs = audioController.songList
            .where((song) => song.title.toLowerCase().contains(searchQuery))
            .toList();

        return ListView.builder(
          itemCount: filteredSongs.length,
          padding: const EdgeInsets.only(top: 70.0, bottom: 85), // Adjust padding for the search bar and minimized player
          itemBuilder: (context, index) {
            final song = filteredSongs[index];
            return Obx(() {
              return ListTile(
                leading: _buildSongImage(song.image), // Add song image
                trailing: audioController.currentIndex.value == audioController.songList.indexOf(song)
                    ? const Icon(Icons.music_note, color: Colors.deepPurple) // Icon indicating the current playing song
                    : null,
                title: Text(song.title),
                subtitle: Text(song.artist.toString()),
                onTap: () {
                  audioController.currentIndex.value = audioController.songList.indexOf(song);
                  audioController.play(uri: song.uri);
                },
              );
            });
          },
        );
      }
    });
  }

  /// Builds the song image for the list tile. If no image, shows a placeholder.
  Widget _buildSongImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.music_note, color: Colors.deepPurple),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CommonFunctions().getImageWidget(
          url: imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  /// Builds the floating search bar for searching songs.
  Widget _buildSearchBar() {
    return Visibility(
      visible: isSearchBarVisible,
      child: Positioned(
        top: 10.0, // Hide or show based on scroll direction
        left: 16.0,
        right: 16.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 6,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase(); // Update search query
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by song name',
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.deepPurple),
                      onPressed: () {
                        setState(() {
                          searchQuery = ''; // Clear the search query
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
