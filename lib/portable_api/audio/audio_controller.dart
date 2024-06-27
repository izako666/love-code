import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioController extends GetxController {
  RxBool isInit = false.obs;
  FlutterSoundPlayer player = FlutterSoundPlayer();
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Rx<Duration> playbackPosition = Duration().obs;
  Rx<Duration> playbackDuration = Duration().obs;
  RxList<double> waveformData = RxList<double>.empty(growable: true);
  StreamSubscription<Food>? _recorderSubscription;
  @override
  void onInit() {
    initAudioPlugin();
    super.onInit();
  }

  @override
  void onClose() {
    closeAudioPlugin();
    super.onClose();
  }

  Future<void> initAudioPlugin() async {
    await player.openPlayer();
    await recorder.openRecorder();
    isInit.value = true;
  }

  Future<void> closeAudioPlugin() async {
    await player.closePlayer();
    await recorder.closeRecorder();
    isInit.value = false;
  }

  Future<File> createFile(String id) async {
    var tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/$id.pcm';
    var outputFile = File(path);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile;
  }

  IOSink returnSink(File file) {
    return file.openWrite();
  }

  Future<File?> startRecording() async {
    PermissionStatus status = await Permission.microphone.request();
    var tempDir = await getTemporaryDirectory();
    if (status == PermissionStatus.denied) return null;
    String id = Uuid().v4();
    File outputFile = await createFile(id);
    IOSink sink = returnSink(outputFile);

    var recordingDataController = StreamController<Food>();
    _recorderSubscription = recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        processAudioBuffer(buffer.data!);
        sink.add(buffer.data!);
      }
    });
    recorder.startRecorder(
        toStream: recordingDataController.sink,
        codec: Codec.pcm16,
        bufferSize: 20480);
    return outputFile;
  }

  Future<String?> endRecording() async {
    await _recorderSubscription?.cancel();
    waveformData.clear();
    return await recorder.stopRecorder();
  }

  Future<void> playAudio() async {
    playbackDuration.value = (await player.startPlayer()) ?? Duration();
    player.onProgress!.listen((e) {
      playbackPosition.value = e.position;
      playbackDuration.value = e.duration;
    });
  }

  Future<void> stopAudio() async {
    await player.stopPlayer();
    playbackDuration.value = Duration();
    playbackPosition.value = Duration();
  }

// Function to convert Uint8List to a list of amplitudes
  List<double> convertToAmplitudes(Uint8List buffer) {
    List<double> amplitudes = [];
    for (int i = 0; i < buffer.length; i++) {
      amplitudes.add(buffer[i] / 255.0); // Normalize to 0.0 - 1.0 range
    }
    return amplitudes;
  }

// Function to calculate RMS value from amplitudes
  double calculateRMS(List<double> amplitudes) {
    double sumOfSquares = 0.0;
    for (double amplitude in amplitudes) {
      sumOfSquares += amplitude * amplitude;
    }
    return sqrt(sumOfSquares / amplitudes.length);
  }

// Function to convert RMS value to decibels
  double rmsToDecibels(double rms) {
    if (rms == 0) return -100.0;
    return 20 * log(rms) / ln10; // Convert to decibels (dB)
  }

// Function to normalize decibels to the range 0 to 1
  double normalizeDecibels(double decibels, double minDb, double maxDb) {
    return (decibels - minDb) / (maxDb - minDb);
  }

// Function to process audio buffer and add decibel intensity to a list
  void processAudioBuffer(Uint8List buffer, {minDb = -100, maxDb = 0}) {
    List<double> amplitudes = convertToAmplitudes(buffer);
    double rms = calculateRMS(amplitudes);
    double decibels = rmsToDecibels(rms);
    double normalizedValue = normalizeDecibels(decibels, minDb, maxDb);
    waveformData.add(normalizedValue);
  }
}
