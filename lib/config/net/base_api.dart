import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api.dart';

final Http http = Http();

class Http extends BaseHttp {
  @override
  void init() {
    options.baseUrl = 'https://music.liuzhijin.cn';
    interceptors..add(ApiInterceptor())
        /*// cookie tồn tại không đồng bộ
      ..add(CookieManager(
          PersistCookieJar(dir: StorageManager.temporaryDirectory.path)))*/
        ;
  }
}

class ApiInterceptor extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async {
    debugPrint('---api-request--->url--> ${options.baseUrl}${options.path}' +
        ' queryParameters: ${options.queryParameters}' +
        ' data: ${options.data}');
    return options;
  }

  @override
  onResponse(Response response) {
    debugPrint('---api-response--->resp----->${response.data}');
    ResponseData respData = ResponseData.fromJson(json.decode(response.data));
    if (respData.success) {
      response.data = respData.data;
      return http.resolve(response);
    } else {
      if (respData.code == -1001) {
        // Nếu cookie hết hạn, bạn cần xóa thông tin đăng nhập được lưu trữ cục bộ
        // StorageManager.localStorage.deleteItem(UserModel.keyUser);
        throw const UnAuthorizedException(); // Yêu cầu đăng nhập
      } else {
        throw NotSuccessException.fromRespData(respData);
      }
    }
  }
}

class ResponseData extends BaseResponseData {
  bool get success => 200 == code;

  ResponseData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    error = json['error'];
    data = json['data'];
  }
}
