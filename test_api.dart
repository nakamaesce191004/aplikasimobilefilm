
import 'package:http/http.dart' as http;

void main() async {
  // Attempt to fetch detail for a known slug
  // Slug extraction from previous example: kimi-koete-koi-naru-sub-indo
  final slug = 'kimi-koete-koi-naru-sub-indo'; 
  final url = Uri.parse('https://unofficial-otakudesu-api-ruang-kreatif.vercel.app/api/anime/$slug');
  
  final headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
  };

  try {
    print('Fetching: $url');
    final response = await http.get(url, headers: headers);
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
       print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
