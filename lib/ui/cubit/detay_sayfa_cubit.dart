// lib/ui/cubit/yemek_detay_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/data/repo/yemeklerdao_repository.dart';

// State'ler basitçe sadece işlem durumunu bildirsin
abstract class YemekDetayState {}
class YemekDetayInitial extends YemekDetayState {}
class YemekDetayLoading extends YemekDetayState {}
class YemekDetaySuccess extends YemekDetayState {}
class YemekDetayError extends YemekDetayState {
  final String message;
  YemekDetayError(this.message);
}

class YemekDetayCubit extends Cubit<YemekDetayState> {
  var yrepo = YemeklerDaoRepository();

  YemekDetayCubit() : super(YemekDetayInitial());

  Future<void> sepeteYemekEkle({
    required String yemekAdi,
    required String yemekResimAdi,
    required String yemekFiyat,
    required String yemekSiparisAdet,
    required String kullaniciAdi,
  }) async {
    emit(YemekDetayLoading());
    try {
      await yrepo.sepeteYemekEkle(
        yemekAdi: yemekAdi,
        yemekResimAdi: yemekResimAdi,
        yemekFiyat: yemekFiyat,
        yemekSiparisAdet: yemekSiparisAdet,
        kullaniciAdi: kullaniciAdi,
      );
      emit(YemekDetaySuccess());
    } catch (e) {
      emit(YemekDetayError("Sepete eklenirken bir hata oluştu."));
    }
  }
}