// lib/services/quote_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class QuoteService {
  static const String _apiUrl = 'https://type.fit/api/quotes';
  
  static Future<Map<String, String>> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> quotes = json.decode(response.body);
        
        if (quotes.isEmpty) {
          return _getDefaultQuote();
        }

        final random = Random();
        final selectedQuote = quotes[random.nextInt(quotes.length)];
        
        return {
          'quote': selectedQuote['text']?.toString() ?? '',
          'author': _cleanAuthor(selectedQuote['author']?.toString() ?? 'Anonyme'),
        };
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la citation: $e');
      return _getDefaultQuote();
    }
  }

  static String _cleanAuthor(String author) {
    return author.replaceAll(', type.fit', '').trim();
  }

  static Map<String, String> _getDefaultQuote() {
    final defaultQuotes = [
      {
        'quote': 'Le succès est la somme de petits efforts répétés jour après jour.',
        'author': 'Robert Collier'
      },
      {
        'quote': 'La seule façon de faire du bon travail est d\'aimer ce que vous faites.',
        'author': 'Steve Jobs'
      },
      {
        'quote': 'L\'éducation est l\'arme la plus puissante pour changer le monde.',
        'author': 'Nelson Mandela'
      },
      {
        'quote': 'Ne laissez pas ce que vous ne pouvez pas faire interférer avec ce que vous pouvez faire.',
        'author': 'John Wooden'
      },
      {
        'quote': 'La motivation vous fait commencer. L\'habitude vous fait continuer.',
        'author': 'Jim Ryun'
      },
    ];

    final random = Random();
    return defaultQuotes[random.nextInt(defaultQuotes.length)];
  }

  static Future<List<Map<String, String>>> fetchMultipleQuotes(int count) async {
    try {
      final response = await http.get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> allQuotes = json.decode(response.body);
        final random = Random();
        final selectedQuotes = <Map<String, String>>[];

        for (int i = 0; i < count && i < allQuotes.length; i++) {
          final quote = allQuotes[random.nextInt(allQuotes.length)];
          selectedQuotes.add({
            'quote': quote['text']?.toString() ?? '',
            'author': _cleanAuthor(quote['author']?.toString() ?? 'Anonyme'),
          });
        }

        return selectedQuotes;
      }
    } catch (e) {
      print('Erreur lors de la récupération multiple: $e');
    }

    return [_getDefaultQuote()];
  }
}