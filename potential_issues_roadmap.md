# Spacewar UEFI Derleme ve Paketleme Yol Haritası (Roadmap)

Bu belge, derleme sürecinin kalan aşamalarında ve sonrasında (Cihazda çalışma anı) karşılaşılabilecek olası sorunları ve çözüm stratejilerini içerir.

## 1. Paketleme Aşaması (Step 4: Packaging)

### Sorun: `BootShim.bin` Eksikliği
- **Belirti:** `cat: .../BootShim.bin: No such file or directory`
- **Nedeni:** `edk2-msm` içindeki araçların derlenmemesi.
- **Çözüm:** `build.yml` içine, paketleme öncesinde `make -C edk2-msm/tools/BootShim` komutu eklenecektir.

### Sorun: FV Boyut Aşımı (FV Size Exceeded)
- **Belirti:** `error 0003: FVMAIN Size Exceeded` (Önceki logda doluluk oranı %99 idi).
- **Nedeni:** UEFI imajının (FVMAIN) fiziksel sınırlarını aşması.
- **Çözüm:** `spacewar.fdf.inc` içinden kullanılmayan veya ikincil öncelikli sürücüler (örneğin: `UsbConfigDxe` veya bazı gereksiz sensörler) çıkarılarak yer açılacaktır.

---

## 2. Doğrulama Aşaması (Step 5: Verify Build)

### Sorun: `SimpleInit` Bulunamaması
- **Belirti:** `OK: SimpleInit` yerine `MISSING: SimpleInit` yazması.
- **Nedeni:** SimpleInit kütüphanesinin derlemeye dahil edilmesine rağmen FDF içinde yanlış konumda olması.
- **Çözüm:** `spacewar.fdf.inc` içindeki `SimpleInit` GUID ve yol tanımları kontrol edilecektir.

---

## 3. Çalışma Zamanı (Runtime / Booting)

### Sorun: Siyah Ekran veya GIC Hatası
- **Belirti:** Cihazda hiç görüntü gelmemesi veya seri portta `Synchronous Exception at ArmGicDxe` görülmesi.
- **Nedeni:** GIC (Kesme Kontrolcüsü) adreslerinin (0x17A60000) cihazın aslında kullandığı adresle uyuşmaması.
- **Çözüm:** DTB üzerinden GIC redistributor adresi tekrar kontrol edilip `PlatformMemoryMapLib.c` güncellenecektir.

### Sorun: Boot Loop (Sürekli Yeniden Başlama)
- **Belirti:** "Nothing" logosunda takılma veya sürekli restart.
- **Nedeni:** RAM bölümleri (Memory Map) çakışması veya UEFI'nin kernel tarafından üzerine yazılması.
- **Çözüm:** `spacewar.dsc` içindeki `FD_BASE` adresi değiştirilerek UEFI'nin bellekteki konumu kaydırılacaktır.
