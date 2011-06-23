<h2>Mengenai Walking Papers</h2>

<p>
    OpenStreetMap, menyediakan peta dunia dengan style seperti wikipedia (sering disebut Wikipedia Maps) dimana siapapun dapat mengedit atau merubah konten pada peta. OpenStreetMap masih membutuhkan cara baru untuk menambah kontennya. Walking Papers (Peta jalan) merupakan cara baru dalam menambah data peta dengan menggunakan kertas, yang mempermudah dalam  melakukan pengeditan informasi peta berdasarkan hasil penglihatan selama berjalan atau hasil survey di jalan yang dibutuhkan oleh OSM saat ini, serta mendistribusikan hasilnya sehingga memungkinkan untuk dibaca, catatan yang mudah untuk dipahami dan dibagi serta diubah menjadi data geografis yang benar. 
</p>
<p>
    Walking Papers merupakan alat yang mengimplementasikan ide penggunaan kertas ini, berdasarkan <a href="http://mike.teczno.com/notes/walking-papers.html">
    yaitu eksperimen teknis awal yang dilakukan</a> sejak Februari lalu. 
</p>

<h3>Tiga jenis Pemetaan</h3>

<p>
    Sebuah jaringan di Amerika Serikat sebenarnya telah melengkapi OSM untuk saat ini, sejak adanya impor masal dari US Census Tiger/Line data set. Ini berarti bahwa pihak pemetaan AS bisa jadi kontraproduktif: format partai didesain untuk tempat-tempat dimana jejak baku dari GPS yang paling dibutuhkan dari semua dan peserta sering membuat data baru untuk lokasi yang diberikan untuk pertama kalinya. Jika Anda hadir, maka akan diberikan perangkat GPS genggam, kemudian diajarkan cara menggunakannya, dan dikirim ke lapangan  dengan berjalan kaki atau sepeda atau kendaraan bermotor untuk mengumpulkan data jejak berupa informasi mengenai jalan atau jalur terdekat. 
</p>
<p>
    Karena para pembayar pajak di AS telah mendanai pembuatan data gratis mengenai setiap jalan yang ada di AS untuk publik, jalan umum atau jalan baku umumnya sudah ada di database. Data TIGER bisa jadi kurang akurat, namun dengan menggunakan lisensi dari citra udara Yahoo, maka memungkinkan kita untuk memperbaiki letak jalan yang salah dengan mudah tanpa harus kembali melakukan survey di lapangan - cukup dengan menggunakan OSM’s built-in editor untuk memindahkan jalan kemana pun hingga sesuai dengan yang terlihat pada citra satelit yang mendasarinya. Kegiatan ini bisa jadi cukup menyenangkan dengan <a href="http://en.wikipedia.org/wiki/Obsessive%E2%80%93compulsive_disorder">OCD</a> caranya sendiri, dan kami sendiri telah melewatkan berjam-jam waktu untuk memindahkan node (titik) untuk meningkatkan akurasi dari grid-grid jalan.
</p>
<p>
    Terdapat cara ketiga untuk mengedit peta yang akan memberikan hasil terbaik jika menggunakan kertas, yaitu yang berupa penjelasan dari masyarakat lokal, penggunaan indera penglihatan yang tidak tampak apabila dilihat menggunakan data citra satelit, dan ketidakmungkinan untuk mengumpulkan beberapa data tanpa melakukan kunjungan ke situs atau tempat yang dimaksud: lampu jalan, toko sepeda, toilet, ATM, tangga, kafe, pub,  alamat, dan berbagai konteks geografis lainnya yang membuat OpenStreetMap menjadi pesaing yang kuat dengan menyediakan  layanan komersial yang lebih besar pada skala manusia.
</p>

<h3>Penanganan #3</h3>

<p>
    Saat ini, belum terdapat metode tertentu yang didesain secara spesifik untuk mengatasi jenis ketiga dari pemetaan lokal ini. 
</p>
<p>
    Walking Papers merupakan website dan layanan yang dirancang untuk menutup lingkaran terakhir dari proses pemetaan dengan menyediakan peta-peta cetak OpenStreetMap yang dapat diedit atau ditandai dengan menggunakan pulpen, kemudian di scan kembali ke komputer dan dilacak menggunakan editor berbasis website dari OSM, yaitu Potlatch. Walking papers didesain untuk pembuat peta yang simple yang tidak ingin membawa berbagai gadget untuk merekam data di sekitarnya, pembuat peta yang mungkin hanya ingin berjalan-jalan namun tetap ingin membuat beberapa catatan kemudian membandingkannya dengan data lain milik temannya, dan pembuat peta yang selalu melihat kesempatan untuk membuat catatan-catatan perjalanan kecil selama perjalanannya. Jadi, Walking Papers ini dirancang untuk pembuat peta yang mau membuat untuk membuat perubahan-perubahan isi informasi atau data dan ingin membantu OpenStreetMap, namun membutuhkan bantuan dari kami untuk merubah penjelasan tulisan tangan mereka menjadi data tag dalam OpenStreetMap. 
</p>
<p>
    Kami mencoba menjembatani beberapa penggunaan dengan layanan web dan pemenuhan data non digital. Setiap peta yang telah discan berupa reverse-geocoded menggunakan Flickr’s 
    <a href="http://www.flickr.com/services/api/flickr.places.findByLatLon.html">flickr.places.findByLatLon API feature</a>, yang memberikan nama lokal yang bermakna untuk wilayah geografis tertentu sehingga Anda dapat melihat koleksi scan milik orang lain dan mungkin mengenali wilayah geografis suatu tempat yang Anda ketahui dan mungkin dapat membantu melacak jejaknya. Setiap kegiatan mencetak dan melakukan scan juga didukung oleh pengiriman peta yang telah dicetak kepada user melalui pos, dan untuk menerima pula peta yang telah diedit sebagai balasannya. Apabila anda tidak mendalami ilmu geografi atau tidak memiliki alat scanner yang Anda inginkan, Walking Papers mungkin dapat membantu. 
</p>

<h3>Context</h3>
<p>
    Project ini terutama terinspirasi oleh <a href="http://aaronland.info/">Aaron Cope of Flickr</a> and <a href="http://www.reallyinterestinggroup.com/">Ben / Russell / Tom at Really Interesting Group</a>, yang mana <a href="http://bookcamp.pbworks.com/PaperCamp">Papercamp</a> / <a href="http://aaronland.info/talks/papernet/">Papernet</a> and <a href="http://www.reallyinterestinggroup.com/tofhwoti.html">Things Our Friends Have Written On The Internet 2008</a> membantu seluruh teknologi ini masuk akal.
</p>
<p>
    <a href="mailto:info@walking-papers.org">info@walking-papers.org</a>
    <br />
    <a href="http://github.com/migurski/paperwalking">http://github.com/migurski/paperwalking</a>
</p>
