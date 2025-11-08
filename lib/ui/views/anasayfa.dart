import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yemek_siparis_uygulamasi/anasayfa_state.dart';
import 'package:yemek_siparis_uygulamasi/data/entity/yemekler.dart';
import 'package:yemek_siparis_uygulamasi/ui/cubit/anasayfa_cubit.dart';
import 'package:yemek_siparis_uygulamasi/ui/views/detay_sayfa.dart';
import 'package:yemek_siparis_uygulamasi/ui/views/sepet_sayfa.dart';


class Anasayfa extends StatelessWidget {
  const Anasayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5663FF),
        title: const Text(
          "Merhaba",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Anasayfa.dart dosyasında...

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                // Sepet sayfasına yönlendirme
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SepetSayfa()),
                ).then((value) {
                  // Sepetten geri dönüldüğünde ana sayfayı yenilemek isteyebiliriz.
                  // Örneğin: context.read<AnasayfaCubit>().yemekleriYukle();
                });
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Arama Alanı (Önceki gibi kaldı)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Yemek ara...",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF5663FF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),

          // Yemek Listesi (Cubit Entegrasyonu - Güncellendi)
          Expanded(
            child: BlocBuilder<AnasayfaCubit, AnasayfaState>(
              builder: (context, state) {
                if (state.yukleniyor) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.hataMesaji != null) {
                  return Center(
                    child: Text(
                      state.hataMesaji!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  );
                }

                if (state.yemeklerListesi.isEmpty) {
                  return const Center(
                    child: Text(
                      "Hiç yemek bulunamadı.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Başarılı Yüklenme Durumu
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: state.yemeklerListesi.length,
                  itemBuilder: (context, index) {
                    var yemek = state.yemeklerListesi[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YemekDetay(yemek: yemek),
                          ),
                        );
                      },
                      child: _buildYemekCard(yemek),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYemekCard(Yemekler yemek) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                "http://kasimadalan.pe.hu/yemekler/resimler/${yemek.yemek_resim_adi}",
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yemek.yemek_adi,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₺${yemek.yemek_fiyat}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF5663FF)),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF5663FF))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}