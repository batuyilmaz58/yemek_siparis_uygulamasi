import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/sepetyemekler.dart';
import 'package:yemek_siparis_uygulamasi/ui/cubit/anasayfa_cubit.dart';
import 'package:yemek_siparis_uygulamasi/ui/cubit/sepet_sayfa_cubit.dart';

class SepetSayfa extends StatelessWidget {
  const SepetSayfa({super.key});

  // Sepetten Silme Fonksiyonu
  void sepettenSil(BuildContext context, String sepetYemekId) {
    context.read<SepetCubit>().sepettenSil(sepetYemekId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ürün sepetten silindi.")),
      );
    });
  }

  // Siparişi Onaylama Fonksiyonu ve GIF'li Alert
  void siparisOnayla(BuildContext context, List<SepetYemekler> sepetListesi) {
    // 1. Alert Dialog'u göster
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Siparişiniz Alındı!", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/siparis_basarili.gif', height: 100),
              const SizedBox(height: 16),
              const Text(
                "Yemeğiniz hazırlanıyor ve kısa süre içinde kapınızda olacak.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text("Tamam", style: TextStyle(color: Color(0xFF5663FF), fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Alert'i kapat

                // 2. Sepeti boşaltma işlemi (API çağrısı)
                // Birden fazla ürünü silmek için sepeti silme döngüsü başlatılabilir
                for (var yemek in sepetListesi) {
                  context.read<SepetCubit>().sepettenSil(yemek.sepet_yemek_id);
                }

                // 3. Ana sayfaya geri dön
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Sayfa açıldığında sepeti yüklemeye başla
    context.read<SepetCubit>().sepetiYukle();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Sepetim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              // Sepetten çıkarken ana sayfayı (yemekleri) yenile
              context.read<AnasayfaCubit>().yemekleriYukle();
              Navigator.pop(context);
            }
        ),
      ),
      body: BlocBuilder<SepetCubit, SepetState>(
        builder: (context, state) {
          if (state.yukleniyor) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hataMesaji != null) {
            return Center(child: Text("Hata: ${state.hataMesaji}"));
          }

          if (state.sepetListesi.isEmpty) {
            return const Center(
              child: Text("Sepetinizde ürün bulunmamaktadır.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          List<SepetYemekler> sepetListesi = state.sepetListesi;
          // Toplam tutar hesaplama
          int toplamTutar = sepetListesi.fold(0, (sum, item) => sum + (int.parse(item.yemek_fiyat)));

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 150),
                itemCount: sepetListesi.length,
                itemBuilder: (context, index) {
                  var sepetYemek = sepetListesi[index];
                  return _buildSepetItem(context, sepetYemek);
                },
              ),
              // Güncellenmiş özet kısmı, sipariş onaylama fonksiyonunu çağırır.
              _buildBottomSummary(context, toplamTutar, sepetListesi),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSepetItem(BuildContext context, SepetYemekler sepetYemek) {
    int toplamFiyat = int.parse(sepetYemek.yemek_fiyat);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Resim
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "http://kasimadalan.pe.hu/yemekler/resimler/${sepetYemek.yemek_resim_adi}",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 80, height: 80, child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sepetYemek.yemek_adi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Adet: ${sepetYemek.yemek_siparis_adet}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    "₺${toplamFiyat}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF5663FF)),
                  ),
                ],
              ),
            ),
            // Silme İkonu
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                sepettenSil(context, sepetYemek.sepet_yemek_id);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Sipariş Onaylama Butonunu içeren alt özet
  Widget _buildBottomSummary(BuildContext context, int toplamTutar, List<SepetYemekler> sepetListesi) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Gönderim Ücreti", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const Text("0", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Toplam:", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(
                  "₺${toplamTutar}",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5663FF)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  siparisOnayla(context, sepetListesi); // Onay fonksiyonunu çağır
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC000), // Sarı renk
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "SEPETİ ONAYLA",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}