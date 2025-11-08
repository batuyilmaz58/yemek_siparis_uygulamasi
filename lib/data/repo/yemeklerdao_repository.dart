import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/sepetyemekler.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/sepetyemeklercevap.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/yemekler.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/yemekler_cevap.dart';

class YemeklerDaoRepository {

  // URL'ler (Sabitleri kullanmak daha düzenlidir)
  static const String BASE_URL = "http://kasimadalan.pe.hu/yemekler/";

  // --- Parser Metotları ---

  List<Yemekler> parseYemekler(String cevap){
    return YemeklerCevap.fromJson(json.decode(cevap)).yemekler;
  }

  // Sepet listesini parse eden metot
  List<SepetYemekler> parseSepetYemekler(String cevap) {
    var jsonCevap = json.decode(cevap);

    // API'den sepet boş geldiğinde "sepet_yemekler" alanı null olabilir.
    if (jsonCevap["sepet_yemekler"] == null) {
      return [];
    }
    // Sepet listesi doluysa parse et
    return SepetYemeklerCevap.fromJson(jsonCevap).sepetYemeklerListesi;
  }


  // --- Yemek İşlemleri ---

  // Tüm yemekleri getirir
  Future<List<Yemekler>> yemekleriYukle() async {
    var url = "${BASE_URL}tumYemekleriGetir.php";
    try {
      var cevap = await Dio().get(url);
      return parseYemekler(cevap.data.toString());
    } catch (e) {
      print("Yemekler yüklenirken hata oluştu: $e");
      return []; // Hata durumunda boş liste döndür
    }
  }


  // --- Sepet İşlemleri ---

  // Sepete Yemek Ekleme Metodu
  // Parametreleri String olarak almak, HTTP isteği için daha güvenlidir.
  Future<void> sepeteYemekEkle({
    required String yemekAdi,
    required String yemekResimAdi,
    required String yemekFiyat, // Toplam Fiyat (Adet * Birim Fiyat)
    required String yemekSiparisAdet,
    required String kullaniciAdi,
  }) async {
    var url = "${BASE_URL}sepeteYemekEkle.php";
    var veri = {
      "yemek_adi": yemekAdi,
      "yemek_resim_adi": yemekResimAdi,
      "yemek_fiyat": yemekFiyat,
      "yemek_siparis_adet": yemekSiparisAdet,
      "kullanici_adi": kullaniciAdi,
    };

    try {
      var cevap = await Dio().post(url, data: FormData.fromMap(veri));
      print("Sepete Yemek Ekle Başarılı: ${cevap.data.toString()}");
    } catch (e) {
      print("Sepete Yemek Ekleme Hatası: $e");
    }
  }

  // Sepetteki yemekleri getirir
  Future<List<SepetYemekler>> sepetYemekleriGetir({
    required String kullaniciAdi
  }) async {
    var url = "${BASE_URL}sepettekiYemekleriGetir.php";
    var veri = {"kullanici_adi": kullaniciAdi};

    try {
      var cevap = await Dio().post(url, data: FormData.fromMap(veri));
      return parseSepetYemekler(cevap.data.toString());
    } catch (e) {
      print("Sepet Yemekleri Getirme Hatası: $e");
      return []; // Hata durumunda veya API bağlantı sorununda boş liste döndür
    }
  }


  // Sepetten Yemek Silme Metodu
  // API genellikle sepet_yemek_id ve kullanici_adi ister.
  Future<void> sepettenYemekSil({
    required String sepetYemekId,
    required String kullaniciAdi,
  }) async {
    var url = "${BASE_URL}sepettenYemekSil.php";
    var veri = {
      "sepet_yemek_id": sepetYemekId,
      "kullanici_adi": kullaniciAdi, // API bu parametreyi bekler
    };

    try {
      var cevap = await Dio().post(url, data: FormData.fromMap(veri));
      print("Sepetten Silme Başarılı: ${cevap.data.toString()}");
    } catch (e) {
      print("Sepetten Silme Hatası: $e");
    }
  }
}