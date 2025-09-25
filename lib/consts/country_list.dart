import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetch country names from REST Countries API
Future<List<String>> fetchCountries() async {
  final url = Uri.parse("https://restcountries.com/v3.1/all?fields=name");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List data = json.decode(response.body);

    // Extract common country names and sort them alphabetically
    final countries =
        data
            .map((c) => c['name']?['common'] as String?)
            .where((c) => c != null)
            .cast<String>()
            .toList()
          ..sort();

    return countries;
  } else {
    throw Exception("Failed to load countries: ${response.body}");
  }
}
