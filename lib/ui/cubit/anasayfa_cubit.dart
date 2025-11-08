import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/anasayfa_state.dart';
import 'package:yemek_siparis_uygulamasi/data/repo/yemeklerdao_repository.dart'; 

class AnasayfaCubit extends Cubit<AnasayfaState> {
  var yrepo = YemeklerDaoRepository();

  // Başlangıç state'ini set ediyoruz
  AnasayfaCubit() : super(AnasayfaState.initial()) {
    yemekleriYukle();
  }

  Future<void> yemekleriYukle() async {
    try {
      // Yükleniyor durumunu set et
      emit(state.copyWith(yukleniyor: true, hataMesaji: null));

      var liste = await yrepo.yemekleriYukle();

      // Başarılı yüklenme durumunu set et
      emit(state.copyWith(
        yemeklerListesi: liste,
        yukleniyor: false,
      ));
    } catch (e) {
      print("Yemek yüklenirken hata oluştu: $e");
      // Hata durumunu set et
      emit(state.copyWith(
        yukleniyor: false,
        hataMesaji: "Yemekler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.",
      ));
    }
  }
}