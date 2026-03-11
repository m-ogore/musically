import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

final Dio _dio = Dio();

Future<String> getLocalTrackPath(String hymnId, String trackName) async {
  final directory = await getApplicationDocumentsDirectory();
  final hymnDir = Directory('${directory.path}/audio/$hymnId');
  if (!await hymnDir.exists()) {
    await hymnDir.create(recursive: true);
  }
  return '${hymnDir.path}/$trackName.mp3';
}

Future<bool> isTrackDownloaded(String hymnId, String trackName) async {
  final path = await getLocalTrackPath(hymnId, trackName);
  return File(path).exists();
}

Future<bool> downloadTrack(
  String url,
  String hymnId,
  String trackName, {
  Function(int count, int total)? onReceiveProgress,
}) async {
  try {
    final localPath = await getLocalTrackPath(hymnId, trackName);
    await _dio.download(url, localPath, onReceiveProgress: onReceiveProgress);
    return true;
  } catch (e) {
    debugPrint('Error downloading track $trackName for hymn $hymnId: $e');
    return false;
  }
}

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
