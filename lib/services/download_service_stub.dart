// Stub for platforms where dart:io is not available (e.g. web).
Future<String> getLocalTrackPath(String hymnId, String trackName) async => '';

Future<bool> isTrackDownloaded(String hymnId, String trackName) async => false;

Future<bool> downloadTrack(
  String url,
  String hymnId,
  String trackName, {
  Function(int count, int total)? onReceiveProgress,
}) async => false;

Future<bool> deleteTrack(String hymnId, String trackName) async => true;
