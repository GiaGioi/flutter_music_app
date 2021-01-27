import 'dart:io';

import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class StorageManager {
  /// Cấu hình toàn cầu của ứng dụng, ví dụ: chủ đề
  static SharedPreferences sharedPreferences;

  /// Thư mục tạm thời, ví dụ: cookie
  static Directory temporaryDirectory;


  /// Khởi tạo các thao tác cần thiết, ví dụ: dữ liệu người dùng
  static LocalStorage localStorage;

  /// Khởi tạo dữ liệu cần thiết
  ///
  /// Vì các hoạt động đồng bộ có thể gây ra tắc nghẽn, nên giảm thiểu dung lượng lưu trữ
  static init() async {
    // hoạt động không đồng bộ async
    // hoạt động đồng bộ
    temporaryDirectory = await getTemporaryDirectory();
    sharedPreferences = await SharedPreferences.getInstance();
    localStorage = LocalStorage('LocalStorage');
    await localStorage.ready;
  }
}
