import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/config/storage_manager.dart';
import 'package:flutter_music_app/generated/i18n.dart';
import 'package:flutter_music_app/ui/helper/theme_helper.dart';

//const Color(0xFF5394FF),

class ThemeModel with ChangeNotifier {
  static const kThemeColorIndex = 'kThemeColorIndex';
  static const kThemeUserDarkMode = 'kThemeUserDarkMode';
  static const kFontIndex = 'kFontIndex';

  static const fontValueList = ['system', 'kuaile'];

  /// Chế độ sáng và tối do người dùng chọn
  bool _userDarkMode;

  /// Màu chủ đề hiện tại
  MaterialColor _themeColor;

  /// Chỉ mục phông chữ hiện tại
  int _fontIndex;

  ThemeModel() {
    /// Chế độ sáng và tối do người dùng chọn
    _userDarkMode =
        StorageManager.sharedPreferences.getBool(kThemeUserDarkMode) ?? false;

    /// Nhận màu chủ đề
    _themeColor = Colors.primaries[
        StorageManager.sharedPreferences.getInt(kThemeColorIndex) ?? 5];

    /// Nhận phông chữ
    _fontIndex = StorageManager.sharedPreferences.getInt(kFontIndex) ?? 0;
  }

  int get fontIndex => _fontIndex;

  /// Chuyển màu đã chỉ định
  ///
  /// Không thay đổi độ sáng mà không vượt qua [độ sáng], giống như màu sắc
  void switchTheme({bool userDarkMode, MaterialColor color}) {
    _userDarkMode = userDarkMode ?? _userDarkMode;
    _themeColor = color ?? _themeColor;
    notifyListeners();
    saveTheme2Storage(_userDarkMode, _themeColor);
  }

  /// Màu chủ đề ngẫu nhiên
  ///
  /// Bạn có thể chỉ định chế độ sáng và tối, nếu không chỉ định, nó sẽ không thay đổi
  void switchRandomTheme({Brightness brightness}) {
    int colorIndex = Random().nextInt(Colors.primaries.length - 1);
    switchTheme(
      userDarkMode: Random().nextBool(),
      color: Colors.primaries[colorIndex],
    );
  }

  /// Chuyển đổi phông chữ
  switchFont(int index) {
    _fontIndex = index;
    switchTheme();
    saveFontIndex(index);
  }

  /// Theo ánh sáng chủ đề và bóng râm và màu sắc để tạo ra chủ đề tương ứng
  /// [dark] Chế độ tối của hệ thống
  themeData({bool platformDarkMode: false}) {
    var isDark = platformDarkMode || _userDarkMode;
    Brightness brightness = isDark ? Brightness.dark : Brightness.light;

    var themeColor = _themeColor;
    var accentColor = isDark ? themeColor[800] : _themeColor;
    var scaffoldBackgroundColor = isDark ? Color(0xFF373331) : Colors.white;
    var themeData = ThemeData(
        brightness: brightness,
        // Cho dù màu chủ đề thuộc hệ màu sáng hay hệ màu tối (ví dụ: tối, màu của văn bản AppBarTitle và văn bản trên thanh trạng thái là màu trắng, nếu không thì là màu đen)
        // Mục đích của việc đặt dark ở đây là đặt giá trị mặc định của màu chữ của appBar thành màu trắng bất kể App sáng hay tối.
        // Sử dụng AnnotatedRegion <SystemUiOverlayStyle> để điều chỉnh màu thanh trạng thái phản hồi
        primaryColorBrightness: Brightness.dark,
        accentColorBrightness: Brightness.dark,
        primarySwatch: themeColor,
        accentColor: accentColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        fontFamily: fontValueList[fontIndex]);

    themeData = themeData.copyWith(
      brightness: brightness,
      accentColor: accentColor,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: themeColor,
        brightness: brightness,
      ),

      appBarTheme: themeData.appBarTheme.copyWith(elevation: 0),
      splashColor: themeColor.withAlpha(50),
      hintColor: themeData.hintColor.withAlpha(90),
      errorColor: Colors.red,
      cursorColor: accentColor,
      textTheme: themeData.textTheme.copyWith(

          /// Giải quyết vấn đề gợi ý tiếng Trung không được căn giữa https://github.com/flutter/flutter/issues/40248
          subhead: themeData.textTheme.subhead
              .copyWith(textBaseline: TextBaseline.alphabetic)),
      textSelectionColor: accentColor.withAlpha(60),
      textSelectionHandleColor: accentColor.withAlpha(60),
      toggleableActiveColor: accentColor,
      chipTheme: themeData.chipTheme.copyWith(
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 10),
        labelStyle: themeData.textTheme.caption,
        backgroundColor: themeData.chipTheme.backgroundColor.withOpacity(0.1),
      ),
//          textTheme: CupertinoTextThemeData(brightness: Brightness.light)
      inputDecorationTheme: ThemeHelper.inputDecorationTheme(themeData),
    );
    return themeData;
  }

  /// Dữ liệu liên tục đối với các tùy chọn được chia sẻ
  saveTheme2Storage(bool userDarkMode, MaterialColor themeColor) async {
    var index = Colors.primaries.indexOf(themeColor);
    await Future.wait([
      StorageManager.sharedPreferences
          .setBool(kThemeUserDarkMode, userDarkMode),
      StorageManager.sharedPreferences.setInt(kThemeColorIndex, index)
    ]);
  }

  /// Lấy tên phông chữ theo chỉ mục, liên quan đến quốc tế hóa
  static String fontName(index, context) {
    switch (index) {
      case 0:
        return S.of(context).autoBySystem;
      case 1:
        return S.of(context).fontKuaiLe;
      default:
        return '';
    }
  }

  /// Sự kiên trì lựa chọn phông chữ
  static saveFontIndex(int index) async {
    await StorageManager.sharedPreferences.setInt(kFontIndex, index);
  }
}
