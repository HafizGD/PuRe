-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 29, 2025 at 12:25 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `news_app`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookmarks_news`
--

CREATE TABLE `bookmarks_news` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `link` text DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  `snippet` text DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `thumbnail` text DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `published_at` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookmarks_news`
--

INSERT INTO `bookmarks_news` (`id`, `user_id`, `link`, `title`, `snippet`, `content`, `thumbnail`, `author`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'https://news.com/politik/berita-1', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:41:31'),
(2, 2, 'https://news.com/teknologi/berita-2', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:41:31'),
(3, 2, 'https://update.com/berita/update-3', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:41:31'),
(4, 3, 'https://news.com/hoax/berita-3', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:41:31'),
(14, 5, 'https://bola.okezone.com/read/2025/11/29/51/3186695/media-vietnam-geger-timnas-indonesia-u-22-diperkuat-5-pemain-naturalisasi-di-sea-games-2025-makin-kuat', 'Media Vietnam Geger Timnas Indonesia U-22 Diperkuat 5 Pemain Naturalisasi di SEA Games 2025: Makin Kuat!', 'MEDIA Vietnam, Bao Xay Dung, heboh Timnas Indonesia U-22 diperkuat 5 pemain naturalisasi sekaligus di SEA Games 2025. Mereka menilai skuad Garuda Muda akan makin kuat di SEA Games 2025.\n\nTimnas Indonesia U-22 memang usung target tinggi di SEA Games 2025. Sebab, mereka berstatus juara bertahan.\n\n1. Bawa 5 Pemain Naturalisasi\n\nDi SEA Games 2025, pelatih Timnas Indonesia U-22, Indra Sjafri, panggil 5 pemain naturalisasi. Kelima pemain itu adalah Dion Markx, Ivar Jenner, Rafael Struick, Jens Raven, dan Mauro Zijlstra.\n\nTiga dari lima pemain itu pun diketahui masih berstatus abroad atau berkarier di luar negeri. Ivar Jenner diketahui membela Jong Utrecht, lalu Dion Markx membela klub Belanda Top OSS, terakhir ada Mauro Zijlstra yang memperkuat Volendam.\n\nTak ayal, kualitas para pemain tersebut tak perlu diragukan lagi. Mereka bahkan sudah punya pengalaman membela Timnas Indonesia senior.', 'MEDIA Vietnam, Bao Xay Dung, heboh Timnas Indonesia U-22 diperkuat 5 pemain naturalisasi sekaligus di SEA Games 2025. Mereka menilai skuad Garuda Muda akan makin kuat di SEA Games 2025.\n\nTimnas Indonesia U-22 memang usung target tinggi di SEA Games 2025. Sebab, mereka berstatus juara bertahan.\n\n1. Bawa 5 Pemain Naturalisasi\n\nDi SEA Games 2025, pelatih Timnas Indonesia U-22, Indra Sjafri, panggil 5 pemain naturalisasi. Kelima pemain itu adalah Dion Markx, Ivar Jenner, Rafael Struick, Jens Raven, dan Mauro Zijlstra.\n\nTiga dari lima pemain itu pun diketahui masih berstatus abroad atau berkarier di luar negeri. Ivar Jenner diketahui membela Jong Utrecht, lalu Dion Markx membela klub Belanda Top OSS, terakhir ada Mauro Zijlstra yang memperkuat Volendam.\n\nTak ayal, kualitas para pemain tersebut tak perlu diragukan lagi. Mereka bahkan sudah punya pengalaman membela Timnas Indonesia senior.', 'https://img.okezone.com/content/2025/11/29/51/3186695/timnas_indonesia_u_22-XCVP_large.jpg', NULL, NULL, '2025-11-29 16:23:57', '2025-11-29 16:23:57');

-- --------------------------------------------------------

--
-- Table structure for table `recent_news`
--

CREATE TABLE `recent_news` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `link` text DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  `snippet` text DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `thumbnail` text DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `published_at` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recent_news`
--

INSERT INTO `recent_news` (`id`, `user_id`, `link`, `title`, `snippet`, `content`, `thumbnail`, `author`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 0, 'https://update.com/berita/update-1', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 15:18:19', '2025-11-29 15:52:19'),
(2, 0, 'https://update.com/berita/update-2', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:52:19'),
(3, 0, 'https://update.com/berita/update-3', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-15 23:29:54', '2025-11-29 15:52:19'),
(4, 0, 'https://mediaindonesia.com/sepak-bola/835181/persija-rayakan-ulang-tahun-ke-97-dengan-kemenangan-begini-kata-pelatih', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 15:18:32', '2025-11-29 15:52:19'),
(5, 0, 'https://en.tempo.co/read/2069629/finland-closes-embassies-in-myanmar-afghanistan-and-pakistan', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 15:28:43', '2025-11-29 15:52:19'),
(6, 0, 'https://en.tempo.co/read/2069623/ramen-vs-udon-what-sets-these-two-japanese-noodles-apart', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 15:49:41', '2025-11-29 15:52:19'),
(7, 5, 'https://en.tempo.co/read/2069623/ramen-vs-udon-what-sets-these-two-japanese-noodles-apart', 'Ramen vs. Udon: What Sets These Two Japanese Noodles Apart', 'TEMPO.CO, Jakarta - Two types of Japanese noodles, ramen and udon, are becoming increasingly popular in Indonesia. However, many consumers still consider them the same or only differ in noodle size. These noodles have very different characteristics, from their basic ingredients and texture to their serving style.As reported by MasterClass, Ramen is a chewy, yellow noodle made from wheat flour and alkaline mineral water (kansui), which gives the noodles their bright yellow color and elastic texture. This type of noodle is typically served in a thick, flavorful broth, such as shoyu (soy sauce), miso (soybean paste), tonkotsu (pork bones), or shio (salt). In Indonesia, ramen is available as fresh noodles at Japanese restaurants or in instant packages that only need hot water.Illustration of ramen (Pixabay)Meanwhile, udon is a thick noodle that is typical of the Land of the Rising Sun, made only from wheat flour, water, and salt, without kansui or eggs. Since it doesn\'t contain eggs, udon is a clean white color and naturally suitable for vegans. Its thickness usually ranges from 2 to 4 millimeters, much thicker than ramen, and it has a round or flat shape. Udon is generally served with a light and clean-tasting dashi broth.Massanao Takeda, the Zundo-ya Ramen chef and expert in ramen and udon, explained the differences in noodle-making. According to him, ramen is easier to make because of its strong gluten. \"As for udon, we have to handle the dough very carefully so that the noodle remains strong even without eggs and kansui. That\'s why its texture is very different,\" said Massanao, who was interviewed at the Zundo-ya Gandaria City ramen restaurant in Jakarta on Thursday, November 27, 2025.He explained that this difference in gluten strength is what gives udon its distinctive, dense, and smooth bite, while ramen is more flexible and easily breaks when sucked.Three Main Differences1. Size and ShapeUdon is much thicker and usually straight or slightly flat, whereas ramen is thinner, wavy, and easily absorbs the broth.2. Egg Content and ColorRamen contains eggs in the dough, giving it a yellow color and a chewy texture thanks to its strong gluten. Because udon contains no eggs, it is white and suitable for vegan consumers.3. Broth CharacteristicsRamen broth tends to be thick, savory, and strongly aromatic from hours of boiling. By contrast, udon broth is lighter and clearer with a subtle umami flavor derived from kombu and katsuobushi.As more authentic Japanese restaurants are opening branches in Indonesia, understanding the differences between ramen and udon will help consumers choose a dish according to their preference. For example, they can choose a dish with a thick, warming broth or a dish with thick noodles and a light, refreshing broth.Putri Az zahra Suherman contributed to this articleEditor\'s Choice: Why Ramen Has Overtaken Sushi as Travelers\' Favorite Japanese DishClick here to get the latest news updates from Tempo on Google News', 'TEMPO.CO, Jakarta - Two types of Japanese noodles, ramen and udon, are becoming increasingly popular in Indonesia. However, many consumers still consider them the same or only differ in noodle size. These noodles have very different characteristics, from their basic ingredients and texture to their serving style.As reported by MasterClass, Ramen is a chewy, yellow noodle made from wheat flour and alkaline mineral water (kansui), which gives the noodles their bright yellow color and elastic texture. This type of noodle is typically served in a thick, flavorful broth, such as shoyu (soy sauce), miso (soybean paste), tonkotsu (pork bones), or shio (salt). In Indonesia, ramen is available as fresh noodles at Japanese restaurants or in instant packages that only need hot water.Illustration of ramen (Pixabay)Meanwhile, udon is a thick noodle that is typical of the Land of the Rising Sun, made only from wheat flour, water, and salt, without kansui or eggs. Since it doesn\'t contain eggs, udon is a clean white color and naturally suitable for vegans. Its thickness usually ranges from 2 to 4 millimeters, much thicker than ramen, and it has a round or flat shape. Udon is generally served with a light and clean-tasting dashi broth.Massanao Takeda, the Zundo-ya Ramen chef and expert in ramen and udon, explained the differences in noodle-making. According to him, ramen is easier to make because of its strong gluten. \"As for udon, we have to handle the dough very carefully so that the noodle remains strong even without eggs and kansui. That\'s why its texture is very different,\" said Massanao, who was interviewed at the Zundo-ya Gandaria City ramen restaurant in Jakarta on Thursday, November 27, 2025.He explained that this difference in gluten strength is what gives udon its distinctive, dense, and smooth bite, while ramen is more flexible and easily breaks when sucked.Three Main Differences1. Size and ShapeUdon is much thicker and usually straight or slightly flat, whereas ramen is thinner, wavy, and easily absorbs the broth.2. Egg Content and ColorRamen contains eggs in the dough, giving it a yellow color and a chewy texture thanks to its strong gluten. Because udon contains no eggs, it is white and suitable for vegan consumers.3. Broth CharacteristicsRamen broth tends to be thick, savory, and strongly aromatic from hours of boiling. By contrast, udon broth is lighter and clearer with a subtle umami flavor derived from kombu and katsuobushi.As more authentic Japanese restaurants are opening branches in Indonesia, understanding the differences between ramen and udon will help consumers choose a dish according to their preference. For example, they can choose a dish with a thick, warming broth or a dish with thick noodles and a light, refreshing broth.Putri Az zahra Suherman contributed to this articleEditor\'s Choice: Why Ramen Has Overtaken Sushi as Travelers\' Favorite Japanese DishClick here to get the latest news updates from Tempo on Google News', 'https://statik.tempo.co/data/2025/11/28/id_1444224/1444224_720.jpg', 'Mila Novita', NULL, '2025-11-29 16:25:35', '2025-11-29 16:25:35'),
(8, 5, 'https://news.okezone.com/read/2025/11/29/337/3186697/polri-terbangkan-bantuan-logistik-ke-wilayah-sulit-terjangkau-di-aceh-sumut-dan-sumbar', 'Polri Terbangkan Bantuan Logistik ke Wilayah Sulit Terjangkau di Aceh, Sumut dan Sumbar', 'JAKARTA – Polri mengirimkan bantuan logistik via udara untuk mempercepat penyaluran bantuan ke wilayah terdampak bencana di Aceh, Sumatera Utara, dan Sumatera Barat. Pendistribusian itu dilakukan ke wilayah yang sulit dijangkau.\n\nWaastamaops Kapolri, Irjen Laksana, menjelaskan bantuan tersebut dikhususkan untuk masyarakat yang terdampak dan sangat segera memerlukan bantuan.\n“Pagi hari ini kita bersama-sama berada di Pondok Cabe, Pol Udara, untuk melaksanakan pendorongan bantuan kepada masyarakat yang ada di Aceh, Sumatera Utara, dan Sumatera Barat,” kata Laksana di Mako Polisi Udara, Pondok Cabe, Tangerang Selatan, Banten, Sabtu (29/11/2025).\n\nIa menekankan percepatan pengiriman dilakukan agar masyarakat dapat bertahan dalam kondisi darurat. “Pendorongan logistik ini kita upayakan secepatnya agar dapat membantu masyarakat, sehingga mereka dapat bertahan dalam keadaan yang darurat,” ujarnya.\n\nLaksana menjelaskan fasilitas udara telah disiapkan secara maksimal. “Fasilitas udara sudah siap, rekan-rekan bisa lihat sendiri. Dari Mabes Polri kita mendorong bantuan dari Pondok Cabe, sedangkan dari masing-masing polda akan didorong menggunakan kapal terdekat atau helikopter yang ada di polda sekitar,” ucapnya.\n\nPengiriman bantuan dilakukan hari ini dengan mempertimbangkan kondisi cuaca yang tidak menentu. “Bapak Kapolri memerintahkan agar segera membantu menyelesaikan masalah-masalah di daerah terdampak, baik kekurangan bahan makanan, peralatan seperti genset, alat komunikasi, alat-alat SAR seperti perahu karet, pelampung, maupun peralatan medis,” ujarnya.\n\n(Arief Setyadi )', 'JAKARTA – Polri mengirimkan bantuan logistik via udara untuk mempercepat penyaluran bantuan ke wilayah terdampak bencana di Aceh, Sumatera Utara, dan Sumatera Barat. Pendistribusian itu dilakukan ke wilayah yang sulit dijangkau.\n\nWaastamaops Kapolri, Irjen Laksana, menjelaskan bantuan tersebut dikhususkan untuk masyarakat yang terdampak dan sangat segera memerlukan bantuan.\n“Pagi hari ini kita bersama-sama berada di Pondok Cabe, Pol Udara, untuk melaksanakan pendorongan bantuan kepada masyarakat yang ada di Aceh, Sumatera Utara, dan Sumatera Barat,” kata Laksana di Mako Polisi Udara, Pondok Cabe, Tangerang Selatan, Banten, Sabtu (29/11/2025).\n\nIa menekankan percepatan pengiriman dilakukan agar masyarakat dapat bertahan dalam kondisi darurat. “Pendorongan logistik ini kita upayakan secepatnya agar dapat membantu masyarakat, sehingga mereka dapat bertahan dalam keadaan yang darurat,” ujarnya.\n\nLaksana menjelaskan fasilitas udara telah disiapkan secara maksimal. “Fasilitas udara sudah siap, rekan-rekan bisa lihat sendiri. Dari Mabes Polri kita mendorong bantuan dari Pondok Cabe, sedangkan dari masing-masing polda akan didorong menggunakan kapal terdekat atau helikopter yang ada di polda sekitar,” ucapnya.\n\nPengiriman bantuan dilakukan hari ini dengan mempertimbangkan kondisi cuaca yang tidak menentu. “Bapak Kapolri memerintahkan agar segera membantu menyelesaikan masalah-masalah di daerah terdampak, baik kekurangan bahan makanan, peralatan seperti genset, alat komunikasi, alat-alat SAR seperti perahu karet, pelampung, maupun peralatan medis,” ujarnya.\n\n(Arief Setyadi )', 'https://img.okezone.com/content/2025/11/29/337/3186697/polri-PDF2_large.jpg', NULL, NULL, '2025-11-29 16:25:44', '2025-11-29 16:25:44'),
(9, 5, 'https://bola.okezone.com/read/2025/11/29/51/3186695/media-vietnam-geger-timnas-indonesia-u-22-diperkuat-5-pemain-naturalisasi-di-sea-games-2025-makin-kuat', 'Media Vietnam Geger Timnas Indonesia U-22 Diperkuat 5 Pemain Naturalisasi di SEA Games 2025: Makin Kuat!', 'MEDIA Vietnam, Bao Xay Dung, heboh Timnas Indonesia U-22 diperkuat 5 pemain naturalisasi sekaligus di SEA Games 2025. Mereka menilai skuad Garuda Muda akan makin kuat di SEA Games 2025.\n\nTimnas Indonesia U-22 memang usung target tinggi di SEA Games 2025. Sebab, mereka berstatus juara bertahan.\n\n1. Bawa 5 Pemain Naturalisasi\n\nDi SEA Games 2025, pelatih Timnas Indonesia U-22, Indra Sjafri, panggil 5 pemain naturalisasi. Kelima pemain itu adalah Dion Markx, Ivar Jenner, Rafael Struick, Jens Raven, dan Mauro Zijlstra.\n\nTiga dari lima pemain itu pun diketahui masih berstatus abroad atau berkarier di luar negeri. Ivar Jenner diketahui membela Jong Utrecht, lalu Dion Markx membela klub Belanda Top OSS, terakhir ada Mauro Zijlstra yang memperkuat Volendam.\n\nTak ayal, kualitas para pemain tersebut tak perlu diragukan lagi. Mereka bahkan sudah punya pengalaman membela Timnas Indonesia senior.', 'MEDIA Vietnam, Bao Xay Dung, heboh Timnas Indonesia U-22 diperkuat 5 pemain naturalisasi sekaligus di SEA Games 2025. Mereka menilai skuad Garuda Muda akan makin kuat di SEA Games 2025.\n\nTimnas Indonesia U-22 memang usung target tinggi di SEA Games 2025. Sebab, mereka berstatus juara bertahan.\n\n1. Bawa 5 Pemain Naturalisasi\n\nDi SEA Games 2025, pelatih Timnas Indonesia U-22, Indra Sjafri, panggil 5 pemain naturalisasi. Kelima pemain itu adalah Dion Markx, Ivar Jenner, Rafael Struick, Jens Raven, dan Mauro Zijlstra.\n\nTiga dari lima pemain itu pun diketahui masih berstatus abroad atau berkarier di luar negeri. Ivar Jenner diketahui membela Jong Utrecht, lalu Dion Markx membela klub Belanda Top OSS, terakhir ada Mauro Zijlstra yang memperkuat Volendam.\n\nTak ayal, kualitas para pemain tersebut tak perlu diragukan lagi. Mereka bahkan sudah punya pengalaman membela Timnas Indonesia senior.', 'https://img.okezone.com/content/2025/11/29/51/3186695/timnas_indonesia_u_22-XCVP_large.jpg', NULL, NULL, '2025-11-29 18:14:31', '2025-11-29 18:14:31'),
(10, 5, 'https://www.cantika.com/read/2069579/5-tas-tako-yang-stylish-praktis-dan-muat-banyak', '5 Tas Tako yang Stylish, Praktis, dan Muat Banyak', 'INFO CANTIKA.COM - Koleksi tas dari Tako menawarkan desain modern dengan material synthetic leather premium yang awet, tahan air, dan mudah dibersihkan. Banyak model dilengkapi fitur multiways sehingga bisa dipakai sebagai shoulder bag, sling bag, atau backpack sesuai kebutuhan.\n\nTako Bag Miki Multifungsi\n\nTas multifungsi yang bisa dipakai sebagai shoulder bag, slingbag, atau backpack. Berbahan kulit sintetis premium yang tahan air dan mudah dirawat. Ukurannya 35 x 12 x 26 cm, muat laptop dan essentials harian. Terdapat dua saku depan, ruang besar, dan pilihan warna seperti Darkbrown, Black, Burgundy, Green Forest, hingga Mocha Mousse.\n\nTako Cherry Mini Hand Bag dan Sling Bag\n\nTas mini berbahan kulit sintetis premium yang anti air, dengan ukuran 22 x 8 x 17 cm. Meskipun kecil, kapasitasnya besar untuk makeup, dompet kecil, hingga ponsel. Strap 110 cm dapat dilepas sehingga bisa dipakai sebagai handbag atau slingbag. Tersedia warna Red Burgundy, Black Granite, White Snow, Dark Chocolate, dan Pink Sakura.\n\nTako Ruru 3-in-1 Backpack Multifungsi\n\nTas 3-in-1 yang bisa dipakai sebagai backpack, shoulder bag, atau sling bag. Material synthetic leather premium dengan desain vintage modern. Muat laptop hingga 14 inch dan barang harian seperti charger, dompet, buku, dan kosmetik. Ukuran 35.5 x 12.5 x 24.5 cm dan cocok untuk kerja, kuliah, maupun traveling ringan.\n\nTako Ruru 3-in-1 Postman Bag\n\nVariasi lain dari seri Ruru dengan fungsi sama: backpack, slingbag, dan shoulder bag. Memakai synthetic leather premium yang awet dan mudah dibersihkan. Tetap muat laptop 14 inch dengan kapasitas besar, cocok untuk aktivitas padat dari pagi hingga malam.\n\nTako Miko Multifungctional\n\nTas clean dan unisex dengan fungsi multiways: shoulder bag atau backpack. Material leather sintetis awet, ruang sangat lega, dan muat laptop 14 inch. Ukurannya 35.5 x 13 x 24 cm dan dilengkapi banyak kantong untuk kamu yang sering bawa banyak barang. Nyaman digunakan seharian untuk kuliah, kerja, hingga WFC.\n\nKoleksi Tako ini cocok untuk kamu yang aktif dan butuh tas stylish dengan ruang besar. Modelnya versatile, ringan, dan mudah dipadukan dengan berbagai gaya harian.\n\nJika kamu menyukai artikel di atas, cek barang lainnya di Shopee.\n\nHalo Sahabat Cantika, Yuk Update Informasi Terkini Gaya Hidup Cewek Y dan Z di Instagram dan TikTok Cantika.', 'INFO CANTIKA.COM - Koleksi tas dari Tako menawarkan desain modern dengan material synthetic leather premium yang awet, tahan air, dan mudah dibersihkan. Banyak model dilengkapi fitur multiways sehingga bisa dipakai sebagai shoulder bag, sling bag, atau backpack sesuai kebutuhan.\n\nTako Bag Miki Multifungsi\n\nTas multifungsi yang bisa dipakai sebagai shoulder bag, slingbag, atau backpack. Berbahan kulit sintetis premium yang tahan air dan mudah dirawat. Ukurannya 35 x 12 x 26 cm, muat laptop dan essentials harian. Terdapat dua saku depan, ruang besar, dan pilihan warna seperti Darkbrown, Black, Burgundy, Green Forest, hingga Mocha Mousse.\n\nTako Cherry Mini Hand Bag dan Sling Bag\n\nTas mini berbahan kulit sintetis premium yang anti air, dengan ukuran 22 x 8 x 17 cm. Meskipun kecil, kapasitasnya besar untuk makeup, dompet kecil, hingga ponsel. Strap 110 cm dapat dilepas sehingga bisa dipakai sebagai handbag atau slingbag. Tersedia warna Red Burgundy, Black Granite, White Snow, Dark Chocolate, dan Pink Sakura.\n\nTako Ruru 3-in-1 Backpack Multifungsi\n\nTas 3-in-1 yang bisa dipakai sebagai backpack, shoulder bag, atau sling bag. Material synthetic leather premium dengan desain vintage modern. Muat laptop hingga 14 inch dan barang harian seperti charger, dompet, buku, dan kosmetik. Ukuran 35.5 x 12.5 x 24.5 cm dan cocok untuk kerja, kuliah, maupun traveling ringan.\n\nTako Ruru 3-in-1 Postman Bag\n\nVariasi lain dari seri Ruru dengan fungsi sama: backpack, slingbag, dan shoulder bag. Memakai synthetic leather premium yang awet dan mudah dibersihkan. Tetap muat laptop 14 inch dengan kapasitas besar, cocok untuk aktivitas padat dari pagi hingga malam.\n\nTako Miko Multifungctional\n\nTas clean dan unisex dengan fungsi multiways: shoulder bag atau backpack. Material leather sintetis awet, ruang sangat lega, dan muat laptop 14 inch. Ukurannya 35.5 x 13 x 24 cm dan dilengkapi banyak kantong untuk kamu yang sering bawa banyak barang. Nyaman digunakan seharian untuk kuliah, kerja, hingga WFC.\n\nKoleksi Tako ini cocok untuk kamu yang aktif dan butuh tas stylish dengan ruang besar. Modelnya versatile, ringan, dan mudah dipadukan dengan berbagai gaya harian.\n\nJika kamu menyukai artikel di atas, cek barang lainnya di Shopee.\n\nHalo Sahabat Cantika, Yuk Update Informasi Terkini Gaya Hidup Cewek Y dan Z di Instagram dan TikTok Cantika.', 'https://statik.tempo.co/data/2025/11/29/id_1444316/1444316_720.jpg', 'Cantika', NULL, '2025-11-29 17:02:41', '2025-11-29 17:02:41'),
(11, 5, 'https://mediaindonesia.com/nusantara/835210/8-dari-22-korban-hilang-tanah-longsor-tapsel-sumut-ditemukan-tim-basarnas-pekanbaru', '8 dari 22 Korban Hilang Tanah Longsor Tapsel Sumut Ditemukan Tim Basarnas Pekanbaru', 'BENCANA banjir bandang dan tanah longsor di Kampung Duren, Desa Batu Godang, Kecamatan Angkola Sangkunur, Kabupaten Tapanuli Selatan (Tapsel), Sumatra Utara, kembali menelan korban. Tim Basarnas Pekanbaru berhasil menemukan dua korban meninggal dunia tambahan, sehingga total korban ditemukan menjadi delapan orang dari 22 korban hilang.\n\nPenemuan Dua Korban Terbaru\n\nTim Basarnas Pekanbaru menemukan dua korban pada Jumat (28/11) dan Sabtu (29/11):\n\n\n Riska (perempuan) ditemukan pada pukul 18.10 WIB, Jumat (28/11)\n Warso (laki-laki) ditemukan pada pukul 11.55 WIB, Sabtu (29/11)\n\nSebelumnya, hingga Jumat sore (28/11), enam korban meninggal telah ditemukan.\n\nBaca juga : Longsor Dahsyat di Darfur, Sudan, Tewaskan Lebih dari 1.000 Orang\n\nKepala Kantor Pencarian dan Pertolongan Kelas A Pekanbaru, Budi Cahyadi, mengatakan bahwa pihaknya mengerahkan 12 personel untuk memperkuat operasi pencarian bersama tim SAR wilayah Medan.\n\n“Tim Pekanbaru membantu operasi SAR tanah longsor di Sumatra Utara, tepatnya di Kampung Duren, Desa Batu Godang,” ujar Budi, Sabtu (29/11).\n\nKronologi Kejadian Tanah Longsor\n\nKepala Desa Batu Godang, Mahmudin Sihombing, menjelaskan bahwa tanah longsor terjadi pada Rabu (26/11) malam sekitar pukul 21.00 WIB.\n\nBaca juga : 15 Kecamatan di Langkat Terendam Banjir, Warga Mengungsi ke Berbagai Lokasi\n\n\n Total korban: 22 orang\n 14 laki-laki\n 8 perempuan\n Rumah tertimbun: 10 unit\n Mencakup 13 KK (Kepala Keluarga)\n\nProses pencarian dibantu alat berat beko milik PT Hapesong, yang wilayahnya berada di perbatasan lokasi kejadian.\n\nDaftar Korban Belum Ditemukan\n\n\n Parmin – Laki-laki\n Runta – Perempuan\n Edi – Laki-laki\n Semini – Perempuan\n Amanda – Perempuan\n Amel – Perempuan\n Yuda – Laki-laki\n Rizal – Laki-laki\n Basuki – Laki-laki\n Samina – Perempuan\n Canra – Laki-laki\n Dani – Laki-laki\n Reno – Laki-laki\n Zana – Laki-laki\n\n(Catatan: Nama Riska dan Warso sebelumnya tercatat hilang, namun kini sudah ditemukan meninggal.)\n\nKorban yang Sudah Ditemukan Meninggal Dunia\n\n\n Ondos (41) – Laki-laki\n Irwan (29) – Laki-laki\n Ayu (23) – Perempuan\n Jambul (35) – Laki-laki\n Husein (70) – Laki-laki\n Tasya (15) – Perempuan\n Riska – Perempuan\n Warso – Laki-laki\n\nUnsur SAR yang Terlibat\n\nOperasi pencarian dan pertolongan melibatkan berbagai unsur:\n\n\n Basarnas Pekanbaru\n Brimob Polda Sumut\n Bhabinkamtibmas Angkola Sangkunur\n Babinsa Kecamatan Sangkunur\n Satpol PP Angkola Sangkunur\n Aparat Desa Batu Godang\n Masyarakat setempat. (Z-10)', 'BENCANA banjir bandang dan tanah longsor di Kampung Duren, Desa Batu Godang, Kecamatan Angkola Sangkunur, Kabupaten Tapanuli Selatan (Tapsel), Sumatra Utara, kembali menelan korban. Tim Basarnas Pekanbaru berhasil menemukan dua korban meninggal dunia tambahan, sehingga total korban ditemukan menjadi delapan orang dari 22 korban hilang.\n\nPenemuan Dua Korban Terbaru\n\nTim Basarnas Pekanbaru menemukan dua korban pada Jumat (28/11) dan Sabtu (29/11):\n\n\n Riska (perempuan) ditemukan pada pukul 18.10 WIB, Jumat (28/11)\n Warso (laki-laki) ditemukan pada pukul 11.55 WIB, Sabtu (29/11)\n\nSebelumnya, hingga Jumat sore (28/11), enam korban meninggal telah ditemukan.\n\nBaca juga : Longsor Dahsyat di Darfur, Sudan, Tewaskan Lebih dari 1.000 Orang\n\nKepala Kantor Pencarian dan Pertolongan Kelas A Pekanbaru, Budi Cahyadi, mengatakan bahwa pihaknya mengerahkan 12 personel untuk memperkuat operasi pencarian bersama tim SAR wilayah Medan.\n\n“Tim Pekanbaru membantu operasi SAR tanah longsor di Sumatra Utara, tepatnya di Kampung Duren, Desa Batu Godang,” ujar Budi, Sabtu (29/11).\n\nKronologi Kejadian Tanah Longsor\n\nKepala Desa Batu Godang, Mahmudin Sihombing, menjelaskan bahwa tanah longsor terjadi pada Rabu (26/11) malam sekitar pukul 21.00 WIB.\n\nBaca juga : 15 Kecamatan di Langkat Terendam Banjir, Warga Mengungsi ke Berbagai Lokasi\n\n\n Total korban: 22 orang\n 14 laki-laki\n 8 perempuan\n Rumah tertimbun: 10 unit\n Mencakup 13 KK (Kepala Keluarga)\n\nProses pencarian dibantu alat berat beko milik PT Hapesong, yang wilayahnya berada di perbatasan lokasi kejadian.\n\nDaftar Korban Belum Ditemukan\n\n\n Parmin – Laki-laki\n Runta – Perempuan\n Edi – Laki-laki\n Semini – Perempuan\n Amanda – Perempuan\n Amel – Perempuan\n Yuda – Laki-laki\n Rizal – Laki-laki\n Basuki – Laki-laki\n Samina – Perempuan\n Canra – Laki-laki\n Dani – Laki-laki\n Reno – Laki-laki\n Zana – Laki-laki\n\n(Catatan: Nama Riska dan Warso sebelumnya tercatat hilang, namun kini sudah ditemukan meninggal.)\n\nKorban yang Sudah Ditemukan Meninggal Dunia\n\n\n Ondos (41) – Laki-laki\n Irwan (29) – Laki-laki\n Ayu (23) – Perempuan\n Jambul (35) – Laki-laki\n Husein (70) – Laki-laki\n Tasya (15) – Perempuan\n Riska – Perempuan\n Warso – Laki-laki\n\nUnsur SAR yang Terlibat\n\nOperasi pencarian dan pertolongan melibatkan berbagai unsur:\n\n\n Basarnas Pekanbaru\n Brimob Polda Sumut\n Bhabinkamtibmas Angkola Sangkunur\n Babinsa Kecamatan Sangkunur\n Satpol PP Angkola Sangkunur\n Aparat Desa Batu Godang\n Masyarakat setempat. (Z-10)', 'https://asset.mediaindonesia.com/news/2025/11/29/1764408218_10bf95fb2141e8984285.jpeg', NULL, NULL, '2025-11-29 17:32:11', '2025-11-29 17:32:11'),
(12, 5, 'https://mediaindonesia.com/otomotif/835231/mengenal-skema-sewa-kepemilikan-mobil-dan-keuntungannya-untuk-pengguna', 'Mengenal Skema Sewa Kepemilikan Mobil dan Keuntungannya untuk Pengguna', 'SEWA kepemilikan mobil merupakan model penggunaan kendaraan jangka panjang yang menggabungkan konsep sewa dengan peluang kepemilikan. Skema ini berkembang dari tren car subscription di Jepang, lalu disesuaikan agar pengguna dapat memiliki mobil setelah masa langganan selesai.\n\nKonsep ini hadir sebagai alternatif bagi masyarakat yang ingin menggunakan mobil baru tanpa biaya awal tinggi, serta tetap memiliki kesempatan menjadikannya aset setelah periode sewa berakhir.\n\nCara Kerja Sewa Kepemilikan Mobil\n\nSkema ini biasanya menawarkan kontrak jangka panjang, misalnya hingga lima tahun. Selama masa tersebut, pengguna membayar biaya sewa yang telah mencakup berbagai kebutuhan kendaraan. Di akhir masa sewa, mobil dapat dialihkan menjadi milik pengguna sesuai ketentuan yang disepakati di awal.\n\nBaca juga : Ini Hal yang Harus Dilakukan Pengendara Sepeda Motor Saat Terjebak Banjir\n\nModel ini berbeda dari sewa mobil harian atau bulanan biasa, karena berorientasi pada kepemilikan jangka panjang dan tidak sekadar penggunaan sementara.\n\nKeuntungan Sewa Kepemilikan Mobil\n\n1. Tanpa Biaya Awal (Rp0)\n\nBerbeda dengan pembiayaan mobil konvensional yang mewajibkan uang muka hingga 20–30%, skema ini memungkinkan pengguna memulai tanpa DP. Hal ini membantu mereka yang membutuhkan mobil segera tanpa hambatan biaya awal.\n\n2. Kesempatan Memiliki Mobil\n\nDi akhir masa kontrak, kendaraan dapat menjadi milik pengguna. Ini menjadi nilai tambah dibandingkan skema rental biasa yang tidak menawarkan kepemilikan sama sekali.\n\nBaca juga : Ini yang Harus Dilakukan Saat Kendaraan Anda Terendam Banjir\n\n3. Biaya All-in Selama 5 Tahun\n\nSebagian penyedia menawarkan tarif mulai dari sekitar Rp200 ribuan per hari yang sudah mencakup:\n\n\n Pajak kendaraan\n Servis rutin\n Penggantian oli\n Penggantian aki\n Ban dan perawatan komponen tertentu\n\nDengan skema ini, biaya operasional menjadi lebih terprediksi dan pengguna tidak dibebani pengeluaran mendadak.\n\n4. Kebebasan Penggunaan\n\nKendaraan dapat digunakan untuk kebutuhan pribadi maupun pekerjaan, termasuk bepergian ke luar kota. Tidak ada batasan aplikasi, rute tertentu, atau area operasional.\n\n5. Skema Pembayaran Fleksibel\n\nPembayaran dapat dilakukan secara harian, mingguan, atau bulanan, bergantung hasil survei kelayakan. Fleksibilitas ini membantu pengguna menyesuaikan pengeluaran sesuai ritme pendapatan.\n\nSiapa yang Cocok Menggunakan Skema Ini?\n\nModel sewa kepemilikan mobil umumnya banyak dipilih oleh:\n\n\n Pengemudi transportasi online\n Pekerja sektor informal\n Keluarga yang membutuhkan kendaraan tanpa DP\n Pengguna yang ingin memiliki mobil tetapi ingin menghindari proses kredit yang rumit\n\nBagi kelompok dengan pendapatan fluktuatif, skema ini menawarkan keseimbangan antara akses kendaraan dan peluang membangun aset.\n\nDampak Sosial dari Skema Sewa Kepemilikan\n\nPenerapan skema ini berpotensi memutus kemiskinan struktural, terutama bagi pekerja transportasi yang selama ini mengandalkan kendaraan sewaan. Dengan memiliki mobil sendiri, kendaraan tidak hanya menjadi alat mencari penghasilan tetapi juga aset jangka panjang bagi keluarga.\n\nSistem ini tengah diadopsi oleh, movus adalah skema langganan mobil jangka panjang yang menggabungkan fleksibilitas layanan sewa dengan keuntungan kepemilikan mobil. Selama masa berlangganan, customer hanya perlu membayar biaya sewa tanpa harus memikirkan biaya tambahan seperti pajak, servis, atau asuransi. Setelah masa sewa selesai, kendaraan dapat menjadi milik customer.\n\nDengan sistem ini, movus, perusahaan penyedia solusi mobilitas. Sistem yang diadaptasi dari Jepang ini, berupaya memutus rantai kemiskinan struktural, terutama bagi pekerja transportasi online. Mereka memberikan kesempatan memiliki kendaraan sebagai aset jangka panjang.\n\n\"Banyak pengguna, terutama pengemudi online, terjebak dalam kondisi ekonomi yang sulit karena kendaraan yang mereka gunakan bukan milik mereka sendiri. Dengan skema sewa kepemilikan, kendaraan diharapkan dapat menjadi aset produktif yang mendukung stabilitas ekonomi keluarga di masa depan,\" kata Marketing Manager movus, M Rois Am, kemarin.\n\nM Rois Am menambahkan, movus inklusif dan terbuka untuk online driver, pengusaha, pedagang, pegawai swasta, ASN, supir transportasi publik atau taxi, freelancer, hingga yang baru terkena PHK. Proses pendaftaran hingga serah terima kendaraan hanya membutuhkan waktu kurang lebih 2 minggu.\n\nSewa kepemilikan mobil merupakan alternatif menarik bagi masyarakat yang ingin memiliki kendaraan tanpa DP dan tanpa repot mengurus biaya perawatan selama masa penggunaan. Dengan biaya yang lebih stabil, peluang kepemilikan di akhir masa sewa, serta fleksibilitas penggunaan, skema ini menjadi pilihan yang semakin diminati di Indonesia. (Z-10)', 'SEWA kepemilikan mobil merupakan model penggunaan kendaraan jangka panjang yang menggabungkan konsep sewa dengan peluang kepemilikan. Skema ini berkembang dari tren car subscription di Jepang, lalu disesuaikan agar pengguna dapat memiliki mobil setelah masa langganan selesai.\n\nKonsep ini hadir sebagai alternatif bagi masyarakat yang ingin menggunakan mobil baru tanpa biaya awal tinggi, serta tetap memiliki kesempatan menjadikannya aset setelah periode sewa berakhir.\n\nCara Kerja Sewa Kepemilikan Mobil\n\nSkema ini biasanya menawarkan kontrak jangka panjang, misalnya hingga lima tahun. Selama masa tersebut, pengguna membayar biaya sewa yang telah mencakup berbagai kebutuhan kendaraan. Di akhir masa sewa, mobil dapat dialihkan menjadi milik pengguna sesuai ketentuan yang disepakati di awal.\n\nBaca juga : Ini Hal yang Harus Dilakukan Pengendara Sepeda Motor Saat Terjebak Banjir\n\nModel ini berbeda dari sewa mobil harian atau bulanan biasa, karena berorientasi pada kepemilikan jangka panjang dan tidak sekadar penggunaan sementara.\n\nKeuntungan Sewa Kepemilikan Mobil\n\n1. Tanpa Biaya Awal (Rp0)\n\nBerbeda dengan pembiayaan mobil konvensional yang mewajibkan uang muka hingga 20–30%, skema ini memungkinkan pengguna memulai tanpa DP. Hal ini membantu mereka yang membutuhkan mobil segera tanpa hambatan biaya awal.\n\n2. Kesempatan Memiliki Mobil\n\nDi akhir masa kontrak, kendaraan dapat menjadi milik pengguna. Ini menjadi nilai tambah dibandingkan skema rental biasa yang tidak menawarkan kepemilikan sama sekali.\n\nBaca juga : Ini yang Harus Dilakukan Saat Kendaraan Anda Terendam Banjir\n\n3. Biaya All-in Selama 5 Tahun\n\nSebagian penyedia menawarkan tarif mulai dari sekitar Rp200 ribuan per hari yang sudah mencakup:\n\n\n Pajak kendaraan\n Servis rutin\n Penggantian oli\n Penggantian aki\n Ban dan perawatan komponen tertentu\n\nDengan skema ini, biaya operasional menjadi lebih terprediksi dan pengguna tidak dibebani pengeluaran mendadak.\n\n4. Kebebasan Penggunaan\n\nKendaraan dapat digunakan untuk kebutuhan pribadi maupun pekerjaan, termasuk bepergian ke luar kota. Tidak ada batasan aplikasi, rute tertentu, atau area operasional.\n\n5. Skema Pembayaran Fleksibel\n\nPembayaran dapat dilakukan secara harian, mingguan, atau bulanan, bergantung hasil survei kelayakan. Fleksibilitas ini membantu pengguna menyesuaikan pengeluaran sesuai ritme pendapatan.\n\nSiapa yang Cocok Menggunakan Skema Ini?\n\nModel sewa kepemilikan mobil umumnya banyak dipilih oleh:\n\n\n Pengemudi transportasi online\n Pekerja sektor informal\n Keluarga yang membutuhkan kendaraan tanpa DP\n Pengguna yang ingin memiliki mobil tetapi ingin menghindari proses kredit yang rumit\n\nBagi kelompok dengan pendapatan fluktuatif, skema ini menawarkan keseimbangan antara akses kendaraan dan peluang membangun aset.\n\nDampak Sosial dari Skema Sewa Kepemilikan\n\nPenerapan skema ini berpotensi memutus kemiskinan struktural, terutama bagi pekerja transportasi yang selama ini mengandalkan kendaraan sewaan. Dengan memiliki mobil sendiri, kendaraan tidak hanya menjadi alat mencari penghasilan tetapi juga aset jangka panjang bagi keluarga.\n\nSistem ini tengah diadopsi oleh, movus adalah skema langganan mobil jangka panjang yang menggabungkan fleksibilitas layanan sewa dengan keuntungan kepemilikan mobil. Selama masa berlangganan, customer hanya perlu membayar biaya sewa tanpa harus memikirkan biaya tambahan seperti pajak, servis, atau asuransi. Setelah masa sewa selesai, kendaraan dapat menjadi milik customer.\n\nDengan sistem ini, movus, perusahaan penyedia solusi mobilitas. Sistem yang diadaptasi dari Jepang ini, berupaya memutus rantai kemiskinan struktural, terutama bagi pekerja transportasi online. Mereka memberikan kesempatan memiliki kendaraan sebagai aset jangka panjang.\n\n\"Banyak pengguna, terutama pengemudi online, terjebak dalam kondisi ekonomi yang sulit karena kendaraan yang mereka gunakan bukan milik mereka sendiri. Dengan skema sewa kepemilikan, kendaraan diharapkan dapat menjadi aset produktif yang mendukung stabilitas ekonomi keluarga di masa depan,\" kata Marketing Manager movus, M Rois Am, kemarin.\n\nM Rois Am menambahkan, movus inklusif dan terbuka untuk online driver, pengusaha, pedagang, pegawai swasta, ASN, supir transportasi publik atau taxi, freelancer, hingga yang baru terkena PHK. Proses pendaftaran hingga serah terima kendaraan hanya membutuhkan waktu kurang lebih 2 minggu.\n\nSewa kepemilikan mobil merupakan alternatif menarik bagi masyarakat yang ingin memiliki kendaraan tanpa DP dan tanpa repot mengurus biaya perawatan selama masa penggunaan. Dengan biaya yang lebih stabil, peluang kepemilikan di akhir masa sewa, serta fleksibilitas penggunaan, skema ini menjadi pilihan yang semakin diminati di Indonesia. (Z-10)', 'https://asset.mediaindonesia.com/news/2025/11/29/1764411738_d0a284004469553dcb78.png', 'Gana Buana', NULL, '2025-11-29 17:37:31', '2025-11-29 17:37:31');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `username` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `password_hash`, `created_at`) VALUES
(1, 'admin', 'hashed_password_123', '2025-11-15 23:29:54'),
(2, 'fawwaz', 'hashed_password_456', '2025-11-15 23:29:54'),
(3, 'guest', 'hashed_password_789', '2025-11-15 23:29:54'),
(4, 'ytu', '$2y$10$E4yVSBvLuA4y3HnVdTkxsuVA0x8q9MOZJ4zQ30lY0uYDYrDG7dZFS', '2025-11-29 14:23:43'),
(5, 'galang', '$2y$10$GDZn8OkewNwD8vcufcami.PKGmbBHoJZfDUkmI/LmSbXrSXmZsdN6', '2025-11-29 14:52:45');

-- --------------------------------------------------------

--
-- Table structure for table `user_validation`
--

CREATE TABLE `user_validation` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `link` text NOT NULL,
  `is_valid` tinyint(1) NOT NULL COMMENT '1 = Valid, 0 = Hoax',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_validation`
--

INSERT INTO `user_validation` (`id`, `user_id`, `link`, `is_valid`, `created_at`, `updated_at`) VALUES
(1, 5, 'https://mediaindonesia.com/nusantara/835210/8-dari-22-korban-hilang-tanah-longsor-tapsel-sumut-ditemukan-tim-basarnas-pekanbaru', 1, '2025-11-29 17:32:15', '2025-11-29 17:32:15'),
(2, 5, 'https://mediaindonesia.com/otomotif/835231/mengenal-skema-sewa-kepemilikan-mobil-dan-keuntungannya-untuk-pengguna', 1, '2025-11-29 17:37:36', '2025-11-29 17:37:36');

-- --------------------------------------------------------

--
-- Table structure for table `validate_news`
--

CREATE TABLE `validate_news` (
  `id` int(11) NOT NULL,
  `link` text DEFAULT NULL,
  `jumlah_valid` int(11) DEFAULT 0,
  `jumlah_tidak_valid` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `validate_news`
--

INSERT INTO `validate_news` (`id`, `link`, `jumlah_valid`, `jumlah_tidak_valid`, `created_at`) VALUES
(7, 'https://mediaindonesia.com/nusantara/835210/8-dari-22-korban-hilang-tanah-longsor-tapsel-sumut-ditemukan-tim-basarnas-pekanbaru', 6, 0, '2025-11-29 17:32:15'),
(8, 'https://mediaindonesia.com/otomotif/835231/mengenal-skema-sewa-kepemilikan-mobil-dan-keuntungannya-untuk-pengguna', 1, 0, '2025-11-29 17:37:37');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookmarks_news`
--
ALTER TABLE `bookmarks_news`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_user_link` (`user_id`,`link`(255));

--
-- Indexes for table `recent_news`
--
ALTER TABLE `recent_news`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_validation`
--
ALTER TABLE `user_validation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_link` (`user_id`,`link`(255)),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `link` (`link`(255)),
  ADD KEY `is_valid` (`is_valid`);

--
-- Indexes for table `validate_news`
--
ALTER TABLE `validate_news`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookmarks_news`
--
ALTER TABLE `bookmarks_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `recent_news`
--
ALTER TABLE `recent_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_validation`
--
ALTER TABLE `user_validation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `validate_news`
--
ALTER TABLE `validate_news`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookmarks_news`
--
ALTER TABLE `bookmarks_news`
  ADD CONSTRAINT `bookmarks_news_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_validation`
--
ALTER TABLE `user_validation`
  ADD CONSTRAINT `user_validation_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
