import 'dart:io';
import 'package:flutter/material.dart';

class CommonFunctions {
  Widget getImageWidget({
    String? url,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
  }) {
    // Placeholder icon if no image URL is provided
    if (url == null) {
      return placeholder ?? const Icon(Icons.music_note, color: Colors.white, size: 40);
    }

    // Common error widget using the placeholder
    Widget defaultErrorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.music_note, color: Colors.white, size: height == null ? 30 : height / 1.7),
    );

    // Handle network image
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: width ?? 40,
        height: height ?? 40,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; // Image loaded successfully
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          // Use the placeholder if available; otherwise, show the default error icon
          return placeholder ?? defaultErrorWidget;
        },
      );
    }
    // Handle asset image
    else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width ?? 40,
        height: height ?? 40,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Use the placeholder if available; otherwise, show the default error icon
          return placeholder ?? defaultErrorWidget;
        },
      );
    }
    // Handle file image
    else {
      return Image.file(
        File(url),
        width: width ?? 40,
        height: height ?? 40,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Use the placeholder if available; otherwise, show the default error icon
          return placeholder ?? defaultErrorWidget;
        },
      );
    }
  }
}
