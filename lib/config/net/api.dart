import 'dart:convert';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_music_app/utils/platform_utils.dart';

// là một chức năng cấp cao nhất
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

abstract class BaseHttp extends DioForNative {
  BaseHttp() {
    /// Xử lý chung ứng dụng tham gia khởi tạo
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

    /////Release，inProduction
    // bool inProduction = bool.fromEnvironment("dart.vm.product");
    // if (!inProduction) {
    //   String proxy = "192.168.2.234:8888";
    //   (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (HttpClient client) {
    //     client.findProxy = (uri) {
    //       //proxy all request to localhost:8888
    //       return "PROXY $proxy";
    //     };
    //     client.badCertificateCallback =
    //         (X509Certificate cert, String host, int port) => true;
    //   };
    // }
    interceptors..add(HeaderInterceptor());
    init();
  }

  void init();
}

/// Header
class HeaderInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async {
    options.connectTimeout = 1000 * 45;
    options.receiveTimeout = 1000 * 45;
    options.contentType = 'application/x-www-form-urlencoded; charset=UTF-8';

    //var appVersion = await PlatformUtils.getAppVersion();
    // var version = Map()
    //   ..addAll({
    //     'appVerison': appVersion,
    //   });
    //options.headers['version'] = version;
    options.headers['X-Requested-With'] = 'XMLHttpRequest';
    //options.headers['platform'] = Platform.operatingSystem;
    return options;
  }
}

///
abstract class BaseResponseData {
  int code = 0;
  String error;
  dynamic data;

  bool get success;

  BaseResponseData({this.code, this.error, this.data});

  @override
  String toString() {
    return 'BaseRespData{code: $code, message: $error, data: $data}';
  }
}

/// Mã của giao diện không trả về ngoại lệ thực sự
class NotSuccessException implements Exception {
  String error;

  NotSuccessException.fromRespData(BaseResponseData respData) {
    error = respData.error;
  }

  @override
  String toString() {
    return 'NotExpectedException{respData: $error}';
  }
}

/// Được sử dụng để không đăng nhập và các quyền khác không đủ, cần chuyển đến trang ủy quyền
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}