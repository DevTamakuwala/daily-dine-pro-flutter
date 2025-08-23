import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

Future<String> encrypt(String password) async {
  final publicKeyString = await rootBundle.loadString('assets/key/public.pem');
  final parser = RSAKeyParser();
  final RSAPublicKey publicKey = parser.parse(publicKeyString) as RSAPublicKey;

  final encrypter = Encrypter(RSA(publicKey: publicKey));
  final encrypted = encrypter.encrypt(password);

  return encrypted.base64;
}