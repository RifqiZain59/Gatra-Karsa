import 'dart:io';
import 'package:flutter/services.dart'; // Untuk rootBundle
import 'package:get/get.dart';
import 'package:image/image.dart' as img; // Paket 'image' untuk proses gambar
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

class DeteksiController extends GetxController {
  // --- VARIABLES ---
  var imageFile = Rx<File?>(null);
  var isAnalyzing = false.obs;
  var label = "".obs;
  var confidence = 0.0.obs;
  var wayangName = "".obs;
  var wayangHistory = "".obs;

  Interpreter? _interpreter;
  List<String> _labels = [];

  // Status Izin Kamera
  final Rx<PermissionStatus> cameraPermissionStatus =
      PermissionStatus.denied.obs;

  // Database Lokal
  final Map<String, Map<String, String>> wayangDatabase = {
    "arjuna": {
      "nama": "Raden Arjuna",
      "sejarah": "Anggota Pandawa yang tampan, ahli memanah.",
    },
    "bima": {
      "nama": "Raden Werkudara (Bima)",
      "sejarah": "Ksatria berotot kawat tulang besi, jujur.",
    },
    "semar": {
      "nama": "Kyai Lurah Semar",
      "sejarah": "Punakawan tertua, penjelmaan dewa.",
    },
    "gatotkaca": {
      "nama": "Raden Gatotkaca",
      "sejarah": "Ksatria Pringgondani yang sakti, bisa terbang.",
    },
  };

  @override
  void onInit() {
    super.onInit();
    checkCameraPermission();
    _loadModel();
    _loadLabels();
  }

  // --- 1. SETUP TFLITE FLUTTER ---
  Future<void> _loadModel() async {
    try {
      // Muat model
      _interpreter = await Interpreter.fromAsset('assets/wayang_model.tflite');
      print("Model loaded successfully");

      // Cek bentuk input model (biasanya [1, 224, 224, 3])
      var inputShape = _interpreter!.getInputTensor(0).shape;
      print("Model Input Shape: $inputShape");
    } catch (e) {
      print("Error loading model: $e");
      Get.snackbar("Error", "Gagal memuat model AI");
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      print("Labels loaded: $_labels");
    } catch (e) {
      print("Error loading labels: $e");
    }
  }

  // --- 2. PERMISSION ---
  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;
    cameraPermissionStatus.value = status;
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    cameraPermissionStatus.value = status;
  }

  // --- 3. IMAGE PICKER ---
  Future<void> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await checkCameraPermission();
      if (!cameraPermissionStatus.value.isGranted) {
        await requestCameraPermission();
        if (!cameraPermissionStatus.value.isGranted) return;
      }
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path);
        // Reset
        label.value = "";
        wayangName.value = "";
        wayangHistory.value = "";

        runDetection();
      }
    } catch (e) {
      print("Error pick image: $e");
    }
  }

  // --- 4. INFERENCE LOGIC (MANUAL) ---
  Future<void> runDetection() async {
    if (imageFile.value == null || _interpreter == null) return;

    isAnalyzing.value = true;

    // Jalankan di isolate terpisah atau background agar UI tidak lag
    // (Di sini kita sederhanakan pakai async biasa)
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // A. Pre-processing Gambar
      // Baca file gambar
      final imageData = File(imageFile.value!.path).readAsBytesSync();
      img.Image? image = img.decodeImage(imageData);

      if (image == null) return;

      // Ambil dimensi input yang diharapkan model
      var inputTensor = _interpreter!.getInputTensor(0);
      var inputShape = inputTensor.shape;
      var modelHeight = inputShape[1];
      var modelWidth = inputShape[2];
      // Tentukan tipe data (float32 atau uint8)
      var inputType = inputTensor.type;

      // Resize gambar sesuai input model (misal 224x224)
      img.Image resizedImage = img.copyResize(
        image,
        width: modelWidth,
        height: modelHeight,
      );

      // Konversi gambar ke Matrix/List
      // Kita buat array [1, 224, 224, 3]
      var input = List.generate(
        1,
        (i) => List.generate(
          modelHeight,
          (y) => List.generate(modelWidth, (x) => List.filled(3, 0.0)),
        ),
      );

      // Mengisi pixel data
      for (var y = 0; y < modelHeight; y++) {
        for (var x = 0; x < modelWidth; x++) {
          var pixel = resizedImage.getPixel(x, y);

          // Normalisasi: (value - mean) / std
          // TFLite v2 default: mean 127.5, std 127.5 (range -1 ke 1)
          // ATAU mean 0.0, std 255.0 (range 0 ke 1)
          // Sesuaikan dengan settingan saat training model Anda.
          // Di sini saya pakai 0-1 (Float) karena umum.

          input[0][y][x][0] = (pixel.r) / 255.0; // R
          input[0][y][x][1] = (pixel.g) / 255.0; // G
          input[0][y][x][2] = (pixel.b) / 255.0; // B
        }
      }

      // B. Siapkan Output Buffer
      // Output shape biasanya [1, jumlah_label]
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var outputBuffer = List.filled(
        outputShape[0] * outputShape[1],
        0.0,
      ).reshape(outputShape);

      // C. Run Inference
      _interpreter!.run(input, outputBuffer);

      // D. Post-processing (Cari nilai tertinggi)
      List<double> resultProbabilities = List<double>.from(outputBuffer[0]);

      double maxScore = 0.0;
      int maxIndex = -1;

      for (int i = 0; i < resultProbabilities.length; i++) {
        if (resultProbabilities[i] > maxScore) {
          maxScore = resultProbabilities[i];
          maxIndex = i;
        }
      }

      // Threshold (Batas keyakinan)
      if (maxScore > 0.5 && maxIndex != -1 && maxIndex < _labels.length) {
        String rawLabel = _labels[maxIndex];
        // Bersihkan label (hapus angka index jika ada di text file)
        String cleanLabel = rawLabel
            .replaceAll(RegExp(r'[0-9]'), '')
            .trim()
            .toLowerCase();

        label.value = cleanLabel;
        confidence.value = maxScore;

        // Ambil info dari Database
        if (wayangDatabase.containsKey(cleanLabel)) {
          var info = wayangDatabase[cleanLabel]!;
          wayangName.value = info['nama']!;
          wayangHistory.value = info['sejarah']!;
        } else {
          wayangName.value = cleanLabel;
          wayangHistory.value = "Info belum tersedia.";
        }
      } else {
        wayangName.value = "Tidak Dikenali";
        wayangHistory.value =
            "Score terlalu rendah: ${(maxScore * 100).toStringAsFixed(1)}%";
      }
    } catch (e) {
      print("Error inference: $e");
      Get.snackbar("Error", "Gagal mendeteksi: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }

  @override
  void onClose() {
    _interpreter?.close();
    super.onClose();
  }
}
