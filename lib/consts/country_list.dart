const List<String> _countries = [
  'United States',
  'Canada',
  'United Kingdom',
  'Australia',
  'India',
  'Germany',
  'France',
  'Japan',
  'China',
  'Brazil',
  'South Africa',
];

Future<List<String>> fetchCountries() async {
  return _countries;
}
