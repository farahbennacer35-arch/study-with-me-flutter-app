// lib/services/quote_cache.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuoteCache {
  static const String _keyQuote = 'cached_quote';
  static const String _keyAuthor = 'cached_author';
  static const String _keyTimestamp = 'cached_quote_timestamp';
  static const String _keyQuotesList = 'cached_quotes_list';
  
  static const Duration _cacheValidity = Duration(hours: 24);

  static Future<void> saveQuote(String quote, String author) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyQuote, quote);
      await prefs.setString(_keyAuthor, author);
      await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  static Future<Map<String, String>?> loadQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final quote = prefs.getString(_keyQuote);
      final author = prefs.getString(_keyAuthor);
      final timestamp = prefs.getInt(_keyTimestamp);

      if (quote == null || author == null || timestamp == null) {
        return null;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheValidity) {
        await clearCache();
        return null;
      }

      return {
        'quote': quote,
        'author': author,
      };
    } catch (e) {
      print('Erreur lors du chargement du cache: $e');
      return null;
    }
  }

  static Future<void> saveQuotesList(List<Map<String, String>> quotes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(quotes);
      await prefs.setString(_keyQuotesList, jsonString);
    } catch (e) {
      print('Erreur lors de la sauvegarde de la liste: $e');
    }
  }

  static Future<List<Map<String, String>>?> loadQuotesList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyQuotesList);
      
      if (jsonString == null) return null;

      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      print('Erreur lors du chargement de la liste: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyQuote);
      await prefs.remove(_keyAuthor);
      await prefs.remove(_keyTimestamp);
    } catch (e) {
      print('Erreur lors de l\'effacement du cache: $e');
    }
  }

  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyTimestamp);
      
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheValidity;
    } catch (e) {
      return false;
    }
  }
}