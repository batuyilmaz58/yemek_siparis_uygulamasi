import 'package:yemek_siparis_uygulamasi/data/entity/yemekler.dart';

class AnasayfaState {
  final List<Yemekler> yemeklerListesi;
  final bool yukleniyor;
  final String? hataMesaji;

  AnasayfaState({
    required this.yemeklerListesi,
    required this.yukleniyor,
    this.hataMesaji,
  });

  // Başlangıç durumu
  factory AnasayfaState.initial() {
    return AnasayfaState(
      yemeklerListesi: [],
      yukleniyor: true, // Başlangıçta yükleniyor kabul edebiliriz
      hataMesaji: null,
    );
  }

  // Yeni state oluşturmak için copyWith metodu
  AnasayfaState copyWith({
    List<Yemekler>? yemeklerListesi,
    bool? yukleniyor,
    String? hataMesaji,
  }) {
    return AnasayfaState(
      yemeklerListesi: yemeklerListesi ?? this.yemeklerListesi,
      yukleniyor: yukleniyor ?? this.yukleniyor,
      hataMesaji: hataMesaji, // Hata mesajı null olabilir
    );
  }
}