import 'dart:typed_data';

class ImageCacheManager {
  static final ImageCacheManager _singleton = ImageCacheManager._internal();

  factory ImageCacheManager() {
    return _singleton;
  }

  ImageCacheManager._internal();

  final Map<String, Uint8List> _imageCache = <String, Uint8List>{};

  Uint8List getImage(String url) {
    return _imageCache[url];
  }

  void cacheImage({String url, Uint8List imageData}) {
    _imageCache[url] = imageData;
  }
}
