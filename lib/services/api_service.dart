import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  // ---------------------------------------------------------------------------
  // MOCK MODE: Returns fake data so the app works without an API Key.
  // ---------------------------------------------------------------------------

  Future<List<Movie>> getTrendingMovies() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _mockMovies.take(5).toList();
  }
  
  Future<List<Movie>> getMoviesByCategory(String category) async {
    await Future.delayed(const Duration(seconds: 1));
    if (category == 'popular') {
      return _mockMovies.skip(2).take(5).toList();
    }
    return _mockMovies.skip(4).take(5).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMovies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Hardcoded Mock Data
  final List<Movie> _mockMovies = [
    Movie(
      id: 1,
      title: 'Avatar: The Way of Water',
      overview: 'Jake Sully lives with his newfound family formed on the extrasolar moon Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na\'vi race to protect their home.',
      posterPath: 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/s16H6tpK2utvwDtzZ8Qy4qm5Emw.jpg',
      voteAverage: 7.7,
      releaseDate: '2022-12-14',
    ),
    Movie(
      id: 2,
      title: 'Oppenheimer',
      overview: 'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb during World War II.',
      posterPath: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/nb3xI8XI3w4pMVZ38VijItyBXux.jpg',
      voteAverage: 8.2,
      releaseDate: '2023-07-19',
    ),
    Movie(
      id: 3,
      title: 'Barbie',
      overview: 'Barbie and Ken are having the time of their lives in the colorful and seemingly perfect world of Barbie Land. However, when they get a chance to go to the real world, they soon discover the joys and perils of living among humans.',
      posterPath: 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/nHf61UzkfFno5X1ofIhugCPus2R.jpg',
      voteAverage: 7.3,
      releaseDate: '2023-07-19',
    ),
    Movie(
      id: 4,
      title: 'Fast X',
      overview: 'Over many missions and against impossible odds, Dom Toretto and his family have outsmarted, out-nerved and outdriven every foe in their path. Now, they confront the most lethal opponent they\'ve ever faced.',
      posterPath: 'https://image.tmdb.org/t/p/w500/fiVW06jE7z9YnO4trhaMEdclSiC.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/4XM8DUTQb3lhLemJC51Jx4Te2Yy.jpg',
      voteAverage: 7.2,
      releaseDate: '2023-05-17',
    ),
    Movie(
      id: 5,
      title: 'Spider-Man: Across the Spider-Verse',
      overview: 'After reuniting with Gwen Stacy, Brooklyn’s full-time, friendly neighborhood Spider-Man is catapulted across the Multiverse, where he encounters the Spider Society, a team of Spider-People charged with protecting the Multiverse’s very existence.',
      posterPath: 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/4HodYYKEIsGOdinkGi2Ucz6X9i0.jpg',
      voteAverage: 8.4,
      releaseDate: '2023-05-31',
    ),
     Movie(
      id: 6,
      title: 'Mission: Impossible - Dead Reckoning Part One',
      overview: 'Ethan Hunt and his IMF team embark on their most dangerous mission yet: To track down a terrifying new weapon that threatens all of humanity before it falls into the wrong hands.',
      posterPath: 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/628Dep6AxEtDxjZoGP78TsOxYbK.jpg',
      voteAverage: 7.6,
      releaseDate: '2023-07-08',
    ),
    Movie(
      id: 7,
      title: 'John Wick: Chapter 4',
      overview: 'With the price on his head ever increasing, John Wick uncovers a path to defeating The High Table. But before he can earn his freedom, Wick must face off against a new enemy with powerful alliances across the globe.',
      posterPath: 'https://image.tmdb.org/t/p/w500/vZloFAK7NmvMGKE7VkF5UHaz0I.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/h8gHn0OzMjvtULseM4YXhDBtAeb.jpg',
      voteAverage: 7.8,
      releaseDate: '2023-03-22',
    ),
    Movie(
      id: 8,
      title: 'The Super Mario Bros. Movie',
      overview: 'While working underground to fix a water main, Brooklyn plumbers-and-brothers Mario and Luigi are transported down a mysterious pipe and wander into a magical new world.',
      posterPath: 'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/9n2tJBplPbgR2ca05hS5CKXwP2c.jpg',
      voteAverage: 7.8,
      releaseDate: '2023-04-05',
    ),
     Movie(
      id: 9,
      title: 'Guardians of the Galaxy Vol. 3',
      overview: 'Peter Quill, still reeling from the loss of Gamora, must rally his team around him to defend the universe along with protecting one of their own.',
      posterPath: 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/5YZbUmjbMa3ClvSW1Wj3D6XGolb.jpg',
      voteAverage: 8.0,
      releaseDate: '2023-05-03',
    ),
    // Additional Movies
    Movie(
      id: 10,
      title: 'The Batman',
      overview: 'In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler.',
      posterPath: 'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/tRS6jvPM9qPrrnx2KRp3ew96Yot.jpg',
      voteAverage: 7.7,
      releaseDate: '2022-03-01',
    ),
    Movie(
      id: 11,
      title: 'Avengers: Endgame',
      overview: 'After the devastating events of Infinity War, the universe is in ruins. With the help of remaining allies, the Avengers assemble once more in order to reverse Thanos actions and restore balance to the universe.',
      posterPath: 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
      voteAverage: 8.3,
      releaseDate: '2019-04-24',
    ),
    Movie(
      id: 12,
      title: 'Agak Laen',
      overview: 'Demi mengejar mimpi untuk mengubah nasib, empat sekawan penjaga rumah hantu di pasar malam mencari cara baru untuk menakuti pengunjung agar selamat dari kebangkrutan. Sialnya, usaha tersebut justru memakan korban jiwa.',
      posterPath: 'https://image.tmdb.org/t/p/w500/5gP8I3Y4qK8vQzC2o3k3k3k3k3k.jpg', // Placeholder ID style
      backdropPath: 'https://image.tmdb.org/t/p/original/n2C6j6N1J3x3k3k3k3k3k.jpg', // Placeholder
      voteAverage: 7.5,
      releaseDate: '2024-02-01',
    ),
    Movie(
      id: 13,
      title: 'Pengabdi Setan 2: Communion',
      overview: 'Beberapa tahun setelah berhasil menyelamatkan diri dari kejadian mengerikan yang membuat mereka kehilangan ibu dan si bungsu Ian, Rini dan adik-adiknya, Toni dan Bondi, serta Bapak tinggal di rumah susun.',
      posterPath: 'https://image.tmdb.org/t/p/w500/5k7k3k3k3k3k3k3k3k3k3.jpg', // Placeholder
      backdropPath: 'https://image.tmdb.org/t/p/original/m2C6j6N1J3x3k3k3k3k3k.jpg', // Placeholder
      voteAverage: 7.2,
      releaseDate: '2022-08-04',
    ),
     Movie(
      id: 14,
      title: 'Sewu Dino',
      overview: 'Sri diterima bekerja untuk keluarga Atmojo dengan bayaran tinggi, karena keunikan yang dimilikinya, yaitu lahir pada hari Jumat Kliwon. Bersama Erna dan Dini, mereka dibawa ke sebuah gubuk tersembunyi di tengah hutan.',
      posterPath: 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg', // Reusing placeholder effective for demo
      backdropPath: 'https://image.tmdb.org/t/p/original/5YZbUmjbMa3ClvSW1Wj3D6XGolb.jpg',
      voteAverage: 6.8,
      releaseDate: '2023-04-19',
    ),
    Movie(
      id: 15,
      title: 'Top Gun: Maverick',
      overview: 'After more than thirty years of service as one of the Navy’s top aviators, and dodging the advancement in rank that would ground him, Pete “Maverick” Mitchell finds himself training a detachment of TOP GUN graduates for a specialized mission no living pilot has ever seen.',
      posterPath: 'https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/odJ4hx6g6vBt4lBWKFD1tI8WS4x.jpg',
      voteAverage: 8.3,
      releaseDate: '2022-05-24',
    ),
    Movie(
      id: 16,
      title: 'Interstellar',
      overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      posterPath: 'https://image.tmdb.org/t/p/w500/gEU2QniL6E8AHtMY4kRFVs56V9G.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
      voteAverage: 8.4,
      releaseDate: '2014-11-05',
    ),
    Movie(
      id: 17,
      title: 'Inception',
      overview: 'Cobb, a skilled thief who commits corporate espionage by infiltrating the subconscious of his targets is offered a chance to regain his old life as payment for a task considered to be impossible: "inception", the implantation of another person\'s idea into a target\'s subconscious.',
      posterPath: 'https://image.tmdb.org/t/p/w500/9gk7admal4ZLvd9Zr53FiJ92fcK.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/s3TBrRGB1jav7wC7kxRFhE324nb.jpg',
      voteAverage: 8.3,
      releaseDate: '2010-07-15',
    ),
    Movie(
      id: 18,
      title: 'The Dark Knight',
      overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle the remaining criminal organizations that plague the streets. The partnership proves to be effective, but they soon find themselves prey to a reign of chaos unleashed by a rising criminal mastermind known to the terrified citizens of Gotham as the Joker.',
      posterPath: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/1P3Zy18Juv24f1nYp9FfWb1v1Y.jpg', // Placeholder
      voteAverage: 8.5,
      releaseDate: '2008-07-14',
    ),
    Movie(
      id: 19,
      title: 'Transformers: Rise of the Beasts',
      overview: 'When a new threat capable of destroying the entire planet emerges, Optimus Prime and the Autobots must team up with a powerful faction known as the Maximals. With the fate of humanity hanging in the balance, humans Noah Diaz and Elena Wallace will do whatever it takes to help the Transformers as they engage in the ultimate battle to save Earth.',
      posterPath: 'https://image.tmdb.org/t/p/w500/gPbM0MK8CP8A174rmUwGsADNYKD.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/2vFuG6bWGyQUzYS9d69E5l85nIz.jpg',
      voteAverage: 7.5,
      releaseDate: '2023-06-06',
    ),
    Movie(
      id: 20,
      title: 'Dune: Part One',
      overview: 'Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe to ensure the future of his family and his people.',
      posterPath: 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
      backdropPath: 'https://image.tmdb.org/t/p/original/lxbegfHbN91I4c1R04c2qYk8yA0.jpg', // Placeholder
      voteAverage: 7.9,
      releaseDate: '2021-09-15',
    ),
    Movie(
      id: 21,
      title: 'Dilan 1990',
      overview: 'Milea, a high school student in Bandung in 1990, meets Dilan, a charming boy who predicts they will meet in the canteen. Dilan\'s persistent and unusual way of wooing Milea slowly wins her over, but his gang involvement complicates things.',
      posterPath: 'https://image.tmdb.org/t/p/w500/7M4qN7US8XpE87t3lC1V3k3k3k.jpg', // Placeholder
      backdropPath: 'https://image.tmdb.org/t/p/original/8M4qN7US8XpE87t3lC1V3k3k3k.jpg', // Placeholder
      voteAverage: 7.4,
      releaseDate: '2018-01-25',
    ),
     Movie(
      id: 22,
      title: 'Imperfect',
      overview: 'Rara, who was born with genes that made her have dark skin and a large body, has to face body shaming from the people around her, including her own mother.',
      posterPath: 'https://image.tmdb.org/t/p/w500/3k3k3k3k3k3k3k3k3k3k3.jpg', // Placeholder
      backdropPath: 'https://image.tmdb.org/t/p/original/2k3k3k3k3k3k3k3k3k3k3.jpg', // Placeholder
      voteAverage: 7.8,
      releaseDate: '2019-12-19',
    ),
  ];
}
