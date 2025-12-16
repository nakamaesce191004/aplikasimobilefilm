import 'package:flutter/material.dart';
import 'home_page_content.dart'; // Import konten halaman home

// Daftar kategori untuk TabBar horizontal
const List<String> categories = [
  'Home',
  'Sports',
  'Series',
  'Movies',
  'Kids',
  'TV',
];

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: Colors.black,

        appBar: _buildCustomAppBar(context),

        bottomNavigationBar: _buildBottomNavigationBar(context),

        body: const TabBarView(
          children: [
            HomePageContent(), // Konten Halaman Utama di Tab 'Home'
            Center(child: Text('Sports Content')),
            Center(child: Text('Series Content')),
            Center(child: Text('Movies Content')),
            Center(child: Text('Kids Content')),
            Center(child: Text('TV Content')),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'FilmKu',
            style: TextStyle(
              color: Color(0xFFFF005D),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Ikon Pencarian dan Profil
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 28),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFFF005D),
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      bottom: TabBar(
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: categories.map((name) => Tab(text: name)).toList(),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live'),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_collection),
          label: 'Shorts',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Watchlist'),
        BottomNavigationBarItem(icon: Icon(Icons.theaters), label: 'MiniDrama'),
      ],
      onTap: (index) {},
    );
  }
}
