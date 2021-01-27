import 'dart:math';

import 'package:flutter_music_app/model/song_model.dart';
import 'package:flutter_music_app/provider/view_state_refresh_list_model.dart';
import 'package:flutter_music_app/service/base_repository.dart';

class HomeModel extends ViewStateRefreshListModel {
  static const albumValueList = ['Nhạc sàn', 'Hoài cổ', 'Nữ ca sĩ', 'Cổ điển', 'Phổ biến'];
  static const forYouValueList = ['Nhạc Trung Quốc', 'Phổ biến', 'Nhạc nhẹ', 'Bảng xếp hạng', 'Douyin'];

  List<Song> _albums;
  List<Song> _forYou;
  List<Song> get albums => _albums;

  List<Song> get forYou => _forYou;
  @override
  Future<List<Song>> loadData({int pageNum}) async {
    List<Future> futures = [];
    Random r = new Random();
    int _randomSongAlbum = r.nextInt(albumValueList.length);
    int _randomSongForYou = r.nextInt(forYouValueList.length);
    String inputAlbums = albumValueList[_randomSongAlbum];
    String inputForYou = forYouValueList[_randomSongForYou];
    futures.add(BaseRepository.fetchSongList(inputAlbums, pageNum));
    futures.add(BaseRepository.fetchSongList(inputForYou, pageNum));

    var result = await Future.wait(futures);
    _albums = result[0];
    _forYou = result[1];
    return result[1];
  }
}
