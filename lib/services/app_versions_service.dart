import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../responses/github_release.dart';
import '../utils/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class AppVersionsService {
  Future<GitHubRelease?> getLatestAppVersion() async {
    var response = await http.get(Uri.parse(
        'https://api.github.com/repos/gilmarferrari/Plan-It/releases/latest'));

    if (response.statusCode == 200) {
      return GitHubRelease.fromJson(jsonDecode(response.body));
    } else {
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      return null;
    }
  }

  Future<void> downloadAppVersion(String downloadUrl, String fileName) async {
    var response = await http.get(Uri.parse(downloadUrl));

    if (response.statusCode == 200) {
      var hasPermission = await PermissionHandler.hasPermission(
          Permission.requestInstallPackages);

      if (hasPermission) {
        var outputDirectory = await getApplicationDocumentsDirectory();
        File file = File('${outputDirectory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFilex.open(file.path);
      } else {
        Fluttertoast.showToast(
          msg: 'Permissão negada',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: response.body,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
