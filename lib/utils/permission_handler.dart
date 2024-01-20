import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> hasPermission(Permission permission) async {
    var permissionStatus = await permission.status;

    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      permissionStatus = await permission.request();

      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        return false;
      }
    }

    return true;
  }
}
