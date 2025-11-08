import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/sepetyemekler.dart';
import 'package:yemek_siparis_uygulamasi/data/repo/yemeklerdao_repository.dart';

// State Sınıfı
class SepetState {
  final List<SepetYemekler> sepetListesi;
  final bool yukleniyor;
  final String? hataMesaji;

  SepetState({
    required this.sepetListesi,
    required this.yukleniyor,
    this.hataMesaji,
  });

  factory SepetState.initial() {
    return SepetState(sepetListesi: [], yukleniyor: true, hataMesaji: null);
  }

  SepetState copyWith({
    List<SepetYemekler>? sepetListesi,
    bool? yukleniyor,
    String? hataMesaji,
  }) {
    return SepetState(
      sepetListesi: sepetListesi ?? this.sepetListesi,
      yukleniyor: yukleniyor ?? this.yukleniyor,
      hataMesaji: hataMesaji,
    );
  }
}

class SepetCubit extends Cubit<SepetState> {
  var yrepo = YemeklerDaoRepository();
  final String KULLANICI_ADI = "batu"; // Sabit kullanıcı adı

  SepetCubit() : super(SepetState.initial());

  Future<void> sepetiYukle() async {
    emit(state.copyWith(yukleniyor: true, hataMesaji: null));
    try {
      var liste = await yrepo.sepetYemekleriGetir(kullaniciAdi: KULLANICI_ADI);
      emit(state.copyWith(sepetListesi: liste, yukleniyor: false));
    } catch (e) {
      emit(state.copyWith(
          yukleniyor: false, hataMesaji: "Sepet yüklenirken hata oluştu."));
    }
  }

  Future<void> sepettenSil(String sepetYemekId) async {
    try {
      // Önce silme işlemini yap
      await yrepo.sepettenYemekSil(
          sepetYemekId: sepetYemekId, kullaniciAdi: KULLANICI_ADI);

      // Sonra sepeti yeniden yükle (güncel listeyi çek)
      await sepetiYukle();
    } catch (e) {
      emit(state.copyWith(
          yukleniyor: false, hataMesaji: "Silme işleminde hata oluştu."));
    }
  }
}