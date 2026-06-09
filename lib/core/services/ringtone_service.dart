import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:developer' as dev;

enum RingtoneSource { system, custom, asset }

class RingtoneModel {
  final String title;
  final String path;
  final RingtoneSource source;

  RingtoneModel({
    required this.title,
    required this.path,
    required this.source,
  });
}

class RingtoneService {
  static const _channel = MethodChannel('com.example.alarmi/ringtones');
  final AudioPlayer _previewPlayer = AudioPlayer();

  Future<List<RingtoneModel>> getSystemRingtones(int type) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getSystemRingtones', {'type': type});
      return result.map((e) {
        final map = Map<String, String>.from(e);
        return RingtoneModel(
          title: map['title']!,
          path: map['uri']!,
          source: RingtoneSource.system,
        );
      }).toList();
    } catch (e) {
      dev.log('RINGTONE_SERVICE: Error fetching system ringtones: $e');
      return [];
    }
  }

  Future<RingtoneModel?> pickCustomRingtone() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return RingtoneModel(
          title: result.files.single.name,
          path: result.files.single.path!,
          source: RingtoneSource.custom,
        );
      }
    } catch (e) {
      dev.log('RINGTONE_SERVICE: Error picking custom ringtone: $e');
    }
    return null;
  }

  Future<void> previewRingtone(String path, RingtoneSource source) async {
    try {
      await _previewPlayer.stop();
      if (source == RingtoneSource.asset) {
        await _previewPlayer.setAsset(path);
      } else {
        // just_audio supports content URIs (system) and file paths (custom)
        await _previewPlayer.setAudioSource(AudioSource.uri(Uri.parse(path)));
      }
      await _previewPlayer.setLoopMode(LoopMode.one);
      await _previewPlayer.play();
    } catch (e) {
      dev.log('RINGTONE_SERVICE: Error previewing ringtone: $e');
    }
  }

  Future<void> stopPreview() async {
    await _previewPlayer.stop();
  }

  void dispose() {
    _previewPlayer.dispose();
  }
}
