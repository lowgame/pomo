# RULES.md: Minimalist Tasarım ve Mühendislik Prensipleri

Bu belge; `pomo` ve lowgame suite ürünleri için geçerli olan temel tasarım, mimari ve etkileşim anayasasıdır. Her kural bağlayıcıdır ve tavizsiz uygulanır.

---

## 1. Varlık Nedeni ve Özcülük (Essentialism)

### Radikal Eleme (Less, but better)
- Çekirdek amaca doğrudan hizmet etmeyen hiçbir özellik, bileşen veya ayar sisteme dahil edilemez.
- Bir özelliğin "kullanışlı olabilme ihtimali", var olması için geçerli bir gerekçe değildir.
- Mükemmellik; eklenecek bir şey kalmadığında değil, çıkarılacak hiçbir şey kalmadığında elde edilir.

### Sıfır Sürtünme ve Bilişsel Ekonomi (Hick's Law)
- Kullanıcının karar verme süresi ve bilişsel yükü asgari düzeyde tutulmalıdır.
- Karmaşık analitikler, grafikler, ses kütüphaneleri yasaktır. Yalnızca durum ve saf tipografi.

---

## 2. Bilgi Tasarımı ve Görsel Disiplin

### Katı 3 Renk Disiplini (Strict 3-Color Rule)
- Renk paleti tavizsiz olarak yalnızca 3 ton ile sınırlandırılır: `#000000`, `#8E8E93`, `#FFFFFF`.
- Dördüncü bir renge (kırmızı uyarılar, sarı sayaçlar, yeşil mola rozetleri) kesinlikle izin verilmez.
- Renk bir süs değil, 3 kademeli bir durum makinesidir:
  - **Zemin:** Siyah / Beyaz arka plan veya saydam LiquidGlass.
  - **Ön Plan (Aktif):** Yüksek kontrastlı aktif sayaç ve metinler.
  - **Nötr Ton (Pasif/Meta):** Devre dışı modlar, yaklaşan seans noktaları, meta veriler (`#8E8E93`).

### Maksimum Veri-Mürekkep Oranı (Data-Ink Ratio)
- Ekrandaki her piksel doğrudan bir durum veya veri taşımalıdır.
- Sıfır dekoratif çerçeve veya gereksiz kutu.

### Katı Izgara ve Geometrik Hizalama (Grid Discipline)
- Tüm bileşenler matematiksel eksen koordinatlarına oturmalıdır.
- Tipografi: `Avenir Next` geometrik font ailesi.

---

## 3. Etkileşim ve Durum Geçişleri

### Modal ve Kesinti Yasağı
- Kullanıcının akışını kesen hiçbir açılır onay kutusu (modal dialog / alert) kullanılamaz.
- Silme ve sıfırlama işlemleri iki aşamalı yerinde doğrulama (in-place armed `×` / `◎`) ile çözülür.

### Sıfır Yerleşim Kayması (Zero Layout Shift)
- Menü çubuğundaki sayaç rakamları monospaced/tabular tasarlanarak saniyeler akarken genişliğin oynaması ve yanındaki menü ikonlarının titremesi engellenir.

---

## 4. Yazılım Mimarisi ve Mühendislik Standartları

### Sıfır Harici Bağımlılık (Zero External Dependencies)
- 100% Native Swift, SwiftUI ve AppKit.
- Paket yöneticisine üçüncü parti kütüphane eklenmez.

### Tüy Sıklet Çıktı (Featherweight Footprint)
- Derleme çıktısı < 1.5 MB, anında açılış (sub-millisecond resident launch).

### Yerel Öncelikli Mimari (Local-First Architecture)
- Veriler `~/Library/Application Support/pomo/` altında JSON olarak saklanır ve otomatik iCloud Drive senkronu yapılır.
