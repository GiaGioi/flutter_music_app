import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'view_state_list_model.dart';

abstract class ViewStateRefreshListModel<T> extends ViewStateListModel<T> {
  /// Số trang của trang đầu tiên của phân trang
  static const int pageNumFirst = 1;

  /// Số mục phân trang
  static const int pageSize = 10;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  RefreshController get refreshController => _refreshController;

  /// Số trang hiện tại
  int _currentPageNum = pageNumFirst;

  /// Kéo xuống để làm mới
  ///
  /// [init] Đây có phải là lần đầu tiên tải không
  /// true: khi Lỗi, cần chuyển sang trang
  /// false: Khi Lỗi, bạn không cần phải chuyển đến trang, đưa ra lời nhắc trực tiếp
  Future<List<T>> refresh({bool init = false}) async {
    try {
      _currentPageNum = pageNumFirst;
      var data = await loadData(pageNum: pageNumFirst);
      if (data.isEmpty) {
        refreshController.refreshCompleted(resetFooterState: true);
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        refreshController.refreshCompleted();
        // 小于分页的数量,禁止上拉加载更多
        if (data.length < pageSize) {
          refreshController.loadNoData();
        } else {
          //防止上次上拉加载更多失败,需要重置状态
          refreshController.loadComplete();
        }
        setIdle();
      }
      return data;
    } catch (e, s) {
      /// Trang đã tải xong dữ liệu, nếu bạn refresh mà báo lỗi thì không nên nhảy thẳng đến trang báo lỗi
      /// Thay vào đó, hiển thị dữ liệu trang trước đó. Đưa ra thông báo lỗi
      if (init) list.clear();
      refreshController.refreshFailed();
      setError(e, s);
      return null;
    }
  }

  /// Kéo lên để tải thêm
  Future<List<T>> loadMore() async {
    try {
      var data = await loadData(pageNum: ++_currentPageNum);
      if (data.isEmpty) {
        _currentPageNum--;
        refreshController.loadNoData();
      } else {
        onCompleted(data);
        list.addAll(data);
        if (data.length < pageSize) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
        notifyListeners();
      }
      return data;
    } catch (e, s) {
      _currentPageNum--;
      refreshController.loadFailed();
      debugPrint('error--->\n' + e.toString());
      debugPrint('statck--->\n' + s.toString());
      return null;
    }
  }

  /// Tải xuống dữ liệu
  Future<List<T>> loadData({int pageNum});

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
