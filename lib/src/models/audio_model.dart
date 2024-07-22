class AudioModel {
  final String title;
  final String artist;
  final String album;
  final String uri;
  final String? image; // Optional image URL
  final Duration duration; // Duration of the audio file
  bool isFavourite; // Whether the song is marked as a favourite
  final String genre; // Genre of the song
  final String fileExtension; // File extension of the song
  final int track; // Track number
  final int albumId; // Album ID
  final int artistId; // Artist ID

  AudioModel({
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    this.image,
    required this.duration,
    this.isFavourite = false,
    required this.genre,
    required this.fileExtension,
    required this.track,
    required this.albumId,
    required this.artistId,
  });
}
