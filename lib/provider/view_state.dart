
/// Loại trạng thái trang
enum ViewState {
  idle,
  busy, //加载中
  empty, //无数据
  error, //加载失败
  unAuthorized, //未登录
}

/// Loại lỗi
enum ErrorType {
  defaultError,
  networkError,
}

class ViewStateError {
  ErrorType errorType;
  String message;
  String errorMessage;

  ViewStateError(this.errorType, {this.message, this.errorMessage}) {
    errorType ??= ErrorType.defaultError;
    message ??= errorMessage;
  }

  /// Các biến sau được thêm vào phương thức get để thuận tiện cho việc viết mã. Nói một cách chính xác, nó không phải là nghiêm ngặt
  get isNetworkError => errorType == ErrorType.networkError;

  @override
  String toString() {
    return 'ViewStateError{errorType: $errorType, message: $message, errorMessage: $errorMessage}';
  }
}

//enum ConnectivityStatus { WiFi, Cellular, Offline }
