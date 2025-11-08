// lib/data/entity/sepet_yemekler_cevap.dart

import 'package:yemek_siparis_uygulamasi/data/entity/sepetyemekler.dart';

class SepetYemeklerCevap {
  List<SepetYemekler> sepetYemeklerListesi;
  int success;

  SepetYemeklerCevap({required this.sepetYemeklerListesi, required this.success});

  factory SepetYemeklerCevap.fromJson(Map<String, dynamic> json) {
    // "sepet_yemekler" listesini çekme
    var jsonArray = json["sepet_yemekler"] as List;

    // Her bir elemanı SepetYemekler objesine dönüştürme
    List<SepetYemekler> sepetYemeklerListesi = jsonArray
        .map((jsonNesnesi) => SepetYemekler.fromJson(jsonNesnesi))
        .toList();

    return SepetYemeklerCevap(
      sepetYemeklerListesi: sepetYemeklerListesi,
      success: json["success"] as int,
    );
  }
}