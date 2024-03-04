
import 'package:flutter/foundation.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class SharingController extends GetxController {
  RxString sharedValue = "Insert Your Link".obs;

  @override
  void onInit() {
    initSharingListener();
    super.onInit();
  }

  void initSharingListener() {
    FlutterSharingIntent.instance.getInitialSharing().then((List<SharedFile>? value) {
      if (value != null && value.isNotEmpty) {
        if (kDebugMode) {
          print("Shared: getInitialMedia => ${value.map((f) => f.value).join(",")}");
        }
        String link = value[0].value.toString();
        sharedValue.value = link;
        downloadVideo(link);
      }
    });
  }

  Future<void> downloadVideo(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        print('Video downloaded successfully');
        String? contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          RegExp regExp = RegExp('filename[^;=\n]*=(([''"]).*?\\2|[^;\n]*)');
          Match match = regExp.firstMatch(contentDisposition)!;
          if (match.groupCount > 0) {
            print(match.group(1)?.replaceAll('"', ''));
          }
        }
      } else {
        print('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading video: $e');
    }
  }

  String? extractFileName(http.Response response) {
    String? contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null) {
      RegExp regExp = RegExp('filename[^;=\n]*=(([''"]).*?\\2|[^;\n]*)');
      Match match = regExp.firstMatch(contentDisposition)!;
      if (match.groupCount > 0) {
        return match.group(1)?.replaceAll('"', '');
      }
    }
    return null;
  }
}