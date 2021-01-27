import 'view_state_model.dart';

abstract class ViewStateListModel<T> extends ViewStateModel {
  ///Dữ liệu trang
  List<T> list = [];

  /// Lần đầu tiên bạn vào khung tải trang
  initData() async {
    setBusy();
    await refresh(init: true);
  }

  // Kéo xuống để làm mới
  refresh({bool init = false}) async {
    try {
      List<T> data = await loadData();
      if (data.isEmpty) {
        list.clear();
        setEmpty();
      } else {
        onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    } catch (e, s) {
      if (init) list.clear();
      setError(e, s);
    }
  }

  // Tải xuống dữ liệu
  Future<List<T>> loadData();

  onCompleted(List<T> data) {}
}
