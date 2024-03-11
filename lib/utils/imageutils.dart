import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

ImageProvider getImagePro(String base6) {
  Image photo = imageFromBase64String(base6);
  return photo.image;
}

///🎬 Returns image from base64 if ur.startsWith('data:image/png;base64,') else returns Network image at address ur
ImageProvider createImage(String ur) {
  try {
    bool isLink = !ur.startsWith('data:image/png;base64,');
    if (isLink) {
      return Image.network(ur).image;
    }
    ur = ur.replaceFirst('data:image/jpeg;base64,', '');
    return getImagePro(ur);
  } catch (e) {
    return AssetImage('assets/images/ihl.png');
  }
}


