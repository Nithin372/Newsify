import 'dart:convert';
import 'package:assignment_application/signupscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class News {
  final String title;
  final String description;
  final String publishedAt;
  final String sourceName;
  final String imageUrl;

  News(
      {required this.title,
      required this.description,
      required this.publishedAt,
      required this.sourceName,
      required this.imageUrl});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        publishedAt: json['publishedAt'] ?? '',
        sourceName: json['source']['name'] ?? '',
        imageUrl: json['urlToImage'] ?? '');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<News> _newsList;
  bool _isLoading = false;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _newsList = [];
    _searchController = TextEditingController();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('news')) {
      final String jsonString = prefs.getString('news')!;
      final List<dynamic> newsJson = jsonDecode(jsonString);
      setState(() {
        _newsList = newsJson.map((json) => News.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      // ignore: prefer_const_declarations
      final String apiUrl =
          'https://newsapi.org/v2/top-headlines?country=us&apiKey=b6c23bafb5184d13acebe10934a13e05';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> newsJson = jsonDecode(response.body)['articles'];
        setState(() {
          _newsList = newsJson.map((json) => News.fromJson(json)).toList();
          _isLoading = false;
        });
        await prefs.setString('news', jsonEncode(newsJson));
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load news');
      }
    }
  }

  List<News> _filteredNews() {
    if (_searchQuery.isNotEmpty) {
      return _newsList
          .where((news) =>
              news.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              news.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              news.sourceName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    } else {
      return _newsList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(email),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Update the search query
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search in Feed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: _filteredNews().length,
                      itemBuilder: (context, index) {
                        final news = _filteredNews()[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                news.imageUrl,
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              news.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8.0),
                                Text(
                                  news.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Published at: ${news.publishedAt}',
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Source: ${news.sourceName}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
