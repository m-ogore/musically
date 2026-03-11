import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  /// Gets the local path where a track should be saved based on hymn ID and track name.
  Future<String> getLocalTrackPath(String hymnId, String trackName) async {
    final directory = await getApplicationDocumentsDirectory();
    final hymnDir = Directory('${directory.path}/audio/$hymnId');
    if (!await hymnDir.exists()) {
      await hymnDir.create(recursive: true);
    }
    return '${hymnDir.path}/$trackName.mp3';
  }

  /// Checks if a track is already downloaded locally.
  Future<bool> isTrackDownloaded(String hymnId, String trackName) async {
    final path = await getLocalTrackPath(hymnId, trackName);
    return File(path).exists();
  }

  /// Downloads a remote track to the local device.
  Future<bool> downloadTrack(
      String url, String hymnId, String trackName,
      {Function(int count, int total)? onReceiveProgress}) async {
    try {
      final localPath = await getLocalTrackPath(hymnId, trackName);
      
      // Attempt to download the file directly to the device
      await _dio.download(
        url,
        localPath,
        onReceiveProgress: onReceiveProgress,
        options: Options(
          headers: {
            // Optional headers if needed
          },
        ),
      );
      
      return true;
    } catch (e) {
      debugPrint('Error downloading track $trackName for hymn $hymnId: $e');
      return false;
    }
  }

  /// Deletes a cached track locally
  Future<bool> deleteTrack(String hymnId, String trackName) async {
    try {
      final path = await getLocalTrackPath(hymnId, trackName);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting track $trackName: $e');
      return false;
    }
  }
}
