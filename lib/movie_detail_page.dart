import 'package:flutter/material.dart';

class MovieDetailPage extends StatelessWidget {
  // Terima data film yang diklik (contoh: judul)
  final String movieTitle;

  const MovieDetailPage({super.key, required this.movieTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(movieTitle),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              movieTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Area Poster/Gambar Film',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Metadata Film
            const Text(
              '2010 • Action • 2h 28m',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Rating
            Row(
              children: [
                const Text(
                  '8.8',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.star, color: Colors.yellow, size: 30),
                const Icon(Icons.star, color: Colors.yellow, size: 30),
                const Icon(Icons.star, color: Colors.yellow, size: 30),
                const Icon(Icons.star, color: Colors.yellow, size: 30),
                const Icon(Icons.star_half, color: Colors.yellow, size: 30),
                const SizedBox(width: 30),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Rate this',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Reviews Header
            const Text(
              'Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Contoh Review
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.black54),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 16,
                      ), // Contoh 5 bintang
                      Text(
                        'A mind-bending masterpiece with stunning visual effects.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
