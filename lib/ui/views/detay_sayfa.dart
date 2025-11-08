import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/yemekler.dart';
import 'package:yemek_siparis_uygulamasi/ui/cubit/detay_sayfa_cubit.dart';

class YemekDetay extends StatefulWidget {
  final Yemekler yemek;
  const YemekDetay({super.key, required this.yemek});

  @override
  State<YemekDetay> createState() => _YemekDetayState();
}

class _YemekDetayState extends State<YemekDetay> {
  int adet = 1;
  late final int eskiFiyat;
  late final int guncelFiyat;
  final String KULLANICI_ADI = "batu";

  // Sabit veya hesaplanmış değerler (Örnek veriler)
  final String tahminiTeslimat = "25-35 dk";
  final String indirimMiktari = "İndirim %10";

  @override
  void initState() {
    super.initState();
    guncelFiyat = int.parse(widget.yemek.yemek_fiyat);
    eskiFiyat = (guncelFiyat / 0.9).round();
  }

  void sepeteEkle(BuildContext context) {
    int toplamFiyat = guncelFiyat * adet;

    context.read<YemekDetayCubit>().sepeteYemekEkle(
        yemekAdi: widget.yemek.yemek_adi,
        yemekResimAdi: widget.yemek.yemek_resim_adi,
        yemekFiyat: toplamFiyat.toString(),
        yemekSiparisAdet: adet.toString(),
        kullaniciAdi: KULLANICI_ADI
    );
  }

  @override
  Widget build(BuildContext context) {
    int toplamSepetFiyati = guncelFiyat * adet;

    return BlocListener<YemekDetayCubit, YemekDetayState>(
      listener: (context, state) {
        if (state is YemekDetaySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${adet} adet ${widget.yemek.yemek_adi} sepete eklendi."),
              backgroundColor: const Color(0xFF5663FF),
            ),
          );
          // Navigator.pop(context);
        } else if (state is YemekDetayError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Ürün Detayı",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Yıldızlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) => Icon(
                        index < 4 ? Icons.star : Icons.star_border, // 4 dolu, 1 boş (Örnek)
                        color: index < 4 ? Colors.orange : Colors.grey.shade300,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Yemek Resmi
                  Image.network(
                    "http://kasimadalan.pe.hu/yemekler/resimler/${widget.yemek.yemek_resim_adi}",
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, size: 150, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Yemek Adı
                  Text(
                    widget.yemek.yemek_adi,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Fiyatlar (Eski ve Yeni)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₺${eskiFiyat}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "₺${guncelFiyat}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Adet Seçme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAdetButton(Icons.remove, () {
                        if (adet > 1) {
                          setState(() => adet--);
                        }
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "$adet",
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildAdetButton(Icons.add, () {
                        setState(() => adet++);
                      }, isAdd: true),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Bilgi Kartları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(tahminiTeslimat, Icons.access_time),
                      _buildInfoChip("Ücretsiz Teslimat", Icons.delivery_dining),
                      _buildInfoChip(indirimMiktari, Icons.local_offer),
                    ],
                  ),
                ],
              ),
            ),

            // Alt Kısım (Sepete Ekle Butonu)
            Align(
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
                child: Row(
                  children: [
                    // Toplam fiyat solda
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Toplam:", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          "₺${toplamSepetFiyati}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5663FF)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Sepete Ekle Butonu
                    Expanded(
                      child: SizedBox(
                        height: 55,
                        child: BlocBuilder<YemekDetayCubit, YemekDetayState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is YemekDetayLoading ? null : () => sepeteEkle(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5663FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is YemekDetayLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "Sepete Ekle",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adet Artırma/Eksiltme Butonu Widget'ı
  Widget _buildAdetButton(IconData icon, VoidCallback onPressed, {bool isAdd = false}) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: isAdd ? const Color(0xFF5663FF) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: isAdd ? Colors.white : Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  // Bilgi Çipi (Teslimat, İndirim vb.)
  Widget _buildInfoChip(String text, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF5663FF)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}