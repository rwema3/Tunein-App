







import 'dart:async';

import 'package:Tunein/utils/MathUtils.dart';
import 'package:audioplayer/audioplayer.dart';

class AudioReceiverService{
  AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, StreamSubscription> _audioPositionSub = new Map<String, StreamSubscription>();
  Map<String, StreamSubscription> _audioStateChangeSub = new Map<String, StreamSubscription>();
  Map<String, StreamSubscription> _audioPlaybkacKeysSub = new Map<String, StreamSubscription>();


  AudioReceiverService();

  Future playSong(String uri, {String album, String title, String artist, String albumArt}){
   return  _audioPlayer.play(uri, title: title, album: album,  albumArt: albumArt, author: artist);
  }

  Future setItem({String uri, String album, String title, String artist, String albumArt}){
   return  _audioPlayer.setItem(uri: uri, title: title, album: album,  albumArt: albumArt, author: artist);
  }

  Future pauseSong(){
    return _audioPlayer.pause();
  }

  Future stopSong(){
    return _audioPlayer.stop();
  }


  Future seek(double seconds){
    return _audioPlayer.seek(seconds);
  }


  StreamSubscription onPositionChanges(Function(Duration) callback){
    String uID = MathUtils.getUniqueId();
    _audioPositionSub[uID] = _audioPlayer.onAudioPositionChanged.listen((Duration duration) {
      callback(duration);
    });
    return _audioPositionSub[uID];
  }

  StreamSubscription onStateChanges(Function(String) callback){
    String uID = MathUtils.getUniqueId();
    _audioStateChangeSub[uID] = _audioPlayer.onPlayerStateChanged.listen((AudioPlayerState state) {
      callback(serializeEnums(state));
    });
    return _audioStateChangeSub[uID];
  }

  StreamSubscription onPlaybackKeys(Function(String) callback){
    String uID = MathUtils.getUniqueId();
    _audioPlaybkacKeysSub[uID] = _audioPlayer.onPlaybackKeyEvent.listen((PlayBackKeys data) {
      callback(serializeEnums(data));
    });
    return _audioPlaybkacKeysSub[uID];
  }


  closeAllSubs(){
    if(_audioPlaybkacKeysSub!=null)_audioPlaybkacKeysSub.forEach((key, element) {element.cancel(); _audioPlaybkacKeysSub.remove(key);});
    if(_audioPositionSub!=null)_audioPositionSub.forEach((key, element) {element.cancel(); _audioPositionSub.remove(key);});
    if(_audioStateChangeSub!=null)_audioStateChangeSub.forEach((key, element) {element.cancel(); _audioStateChangeSub.remove(key);});
  }

  serializeEnums(entry){
    return entry.toString();
  }

  useNotification({bool useNotification, bool cancelWhenPlayingStops}){
    return _audioPlayer.useNotificationMediaControls(useNotification, cancelWhenPlayingStops);
  }

  showNotification(){
    return _audioPlayer.showNotificationMediaControls();
  }

  hideNotification(){
    return _audioPlayer.hideNotificationMediaControls();
  }


}