import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 首页列表的header
// class HomeRefreshHeader extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var strings = RefreshLocalizations.of(context)?.currentLocalization ??
//         EnRefreshString();
//     return ClassicHeader(
//       canTwoLevelText: S.of(context).refreshTwoLevel,
//       textStyle: TextStyle(color: Colors.white),
//       outerBuilder: (child) => HomeSecondFloorOuter(child),
//       twoLevelView: Container(),
//       height: 70 + MediaQuery.of(context).padding.top / 3,
//       refreshingIcon: ActivityIndicator(brightness: Brightness.dark),
//       releaseText: strings.canRefreshText,
//     );
//   }
// }

/// Chân trang chung
///
/// Vì quá trình quốc tế hóa yêu cầu ngữ cảnh nên không thể định cấu hình nó trong [RefreshConfiguration]
class RefresherFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClassicFooter(
//      failedText: S.of(context).loadMoreFailed,
//      idleText: S.of(context).loadMoreIdle,
//      loadingText: S.of(context).loadMoreLoading,
//      noDataText: S.of(context).loadMoreNoData,
    );
  }
}
