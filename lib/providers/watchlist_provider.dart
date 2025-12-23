import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

import '../models/anime.dart';

class WatchlistProvider extends ChangeNotifier {
  List<Movie> _watchlist = [];

  List<Movie> get watchlist => _watchlist;

  WatchlistProvider() {
    _loadWatchlist();
    _loadAnimeWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? watchlistString = prefs.getString('watchlist');
    if (watchlistString != null) {
      final List<dynamic> decodedList = json.decode(watchlistString);
      _watchlist = decodedList.map((item) => Movie.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_watchlist.map((movie) => movie.toJson()).toList());
    await prefs.setString('watchlist', encodedList);
  }

  // Movies
  Future<void> addToWatchlist(Movie movie) async {
    if (!isInWatchlist(movie.id)) {
      _watchlist.add(movie);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int movieId) async {
    _watchlist.removeWhere((movie) => movie.id == movieId);
    await _saveWatchlist();
    notifyListeners();
  }

  bool isInWatchlist(int movieId) {
    return _watchlist.any((movie) => movie.id == movieId);
  }

  // Anime
  List<Anime> _animeWatchlist = [];
  List<Anime> get animeWatchlist => _animeWatchlist;

  Future<void> _loadAnimeWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? watchlistString = prefs.getString('anime_watchlist');
    if (watchlistString != null) {
      final List<dynamic> decodedList = json.decode(watchlistString);
      _animeWatchlist = decodedList.map((item) => Anime.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveAnimeWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(_animeWatchlist.map((anime) => anime.toJson()).toList());
    await prefs.setString('anime_watchlist', encodedList);
  }

  Future<void> addAnimeToWatchlist(Anime anime) async {
    if (!isAnimeInWatchlist(anime.malId)) {
      _animeWatchlist.add(anime);
      await _saveAnimeWatchlist();
      notifyListeners();
    }
  }

  Future<void> removeAnimeFromWatchlist(int animeId) async {
    _animeWatchlist.removeWhere((anime) => anime.malId == animeId);
    await _saveAnimeWatchlist();
    notifyListeners();
  }

  bool isAnimeInWatchlist(int animeId) {
    return _animeWatchlist.any((anime) => anime.malId == animeId);
  }
}
