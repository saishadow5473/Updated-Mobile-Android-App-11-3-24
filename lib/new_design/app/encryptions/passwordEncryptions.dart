import 'package:encrypt/encrypt.dart' as encrypt;

class DataEncryption {
  String encryptAes(String data) {
    final key = encrypt.Key.fromUtf8("SC+1'6-kBVkN>#nxkD%x%)M^5]egQc@]"); //mobile encrypt key
    //final key = encrypt.Key.fromUtf8('va@8*&Asura*&*a7va(*a*7ha8*h&sp3');//web encrypt key
    final iv = encrypt.IV.fromUtf8("Aetx7Ayc-SYW#uBZ"); //mobile iv encrypt key
    //final iv = encrypt.IV.fromUtf8('&a@5CuRiE#%9a^)f');//web iv encrypt key

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }
}
