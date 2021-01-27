import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_app/config/net/api.dart';
import 'package:flutter_music_app/generated/i18n.dart';
import 'package:oktoast/oktoast.dart';

import 'view_state.dart';

class ViewStateModel with ChangeNotifier {
  /// Ngăn tác vụ không đồng bộ hoàn thành sau khi trang bị hủy, dẫn đến lỗi
  bool _disposed = false;

  /// Trạng thái trang hiện tại, mặc định là bận, có thể được chỉ định trong phương pháp xây dựng của viewModel;
  ViewState _viewState;

  /// Xây dựng theo trạng thái
  ///
  /// Lớp con có thể chỉ định trạng thái trang được yêu cầu trong hàm tạo
  /// FooModel (): super (viewState: ViewState.busy);
  ViewStateModel({ViewState viewState})
      : _viewState = viewState ?? ViewState.idle {
    //debugPrint('ViewStateModel---constructor--->$runtimeType');
  }

  ViewState get viewState => _viewState;

  set viewState(ViewState viewState) {
    _viewStateError = null;
    _viewState = viewState;
    notifyListeners();
  }

  ViewStateError _viewStateError;

  ViewStateError get viewStateError => _viewStateError;

  String get errorMessage => _viewStateError?.message;

  /// Các biến sau đây là phương thức get được thêm vào để thuận tiện cho việc viết mã. Nói một cách chính xác, nó không nghiêm ngặt
  bool get busy => viewState == ViewState.busy;

  bool get idle => viewState == ViewState.idle;

  bool get empty => viewState == ViewState.empty;

  bool get error => viewState == ViewState.error;

  bool get unAuthorized => viewState == ViewState.unAuthorized;

  void setIdle() {
    viewState = ViewState.idle;
  }

  void setBusy() {
    viewState = ViewState.busy;
  }

  void setEmpty() {
    viewState = ViewState.empty;
  }

  void setUnAuthorized() {
    viewState = ViewState.unAuthorized;
    onUnAuthorizedException();
  }

  /// Gọi lại trái phép
  void onUnAuthorizedException() {}

  /// [e] Phân loại lỗi và ngoại lệ
  void setError(e, stackTrace, {String message}) {
    ErrorType errorType = ErrorType.defaultError;
    if (e is DioError) {
      e = e.error;
      if (e is UnAuthorizedException) {
        stackTrace = null;

        /// Đã được xử lý trong onUnAuthorizedException
        setUnAuthorized();
        return;
      } else if (e is NotSuccessException) {
        stackTrace = null;
        message = e.error;
      } else {
        errorType = ErrorType.networkError;
      }
    }
    viewState = ViewState.error;
    _viewStateError = ViewStateError(
      errorType,
      message: message,
      errorMessage: e.toString(),
    );
    printErrorStack(e, stackTrace);
  }

  /// Hiển thị thông báo lỗi
  showErrorMessage(context, {String message}) {
    if (viewStateError != null || message != null) {
      if (viewStateError.isNetworkError) {
        message ??= S.of(context).viewStateMessageNetworkError;
      } else {
        message ??= viewStateError.message;
      }
      Future.microtask(() {
        showToast(message, context: context);
      });
    }
  }

  @override
  String toString() {
    return 'BaseModel{_viewState: $viewState, _viewStateError: $_viewStateError}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    debugPrint('view_state_model dispose -->$runtimeType');
    super.dispose();
  }
}

/// [e] là loại lỗi: có thể là Lỗi, Ngoại lệ, Chuỗi
/// [s] là thông tin ngăn xếp
printErrorStack(e, s) {
  debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----error-----↓↓↓↓↓↓↓↓↓↓----->
$e
<-----↑↑↑↑↑↑↑↑↑↑-----error-----↑↑↑↑↑↑↑↑↑↑----->''');
  if (s != null) debugPrint('''
<-----↓↓↓↓↓↓↓↓↓↓-----trace-----↓↓↓↓↓↓↓↓↓↓----->
$s
<-----↑↑↑↑↑↑↑↑↑↑-----trace-----↑↑↑↑↑↑↑↑↑↑----->
    ''');
}
