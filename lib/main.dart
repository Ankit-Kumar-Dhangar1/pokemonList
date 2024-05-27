import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon List'),
        ),
        body: const Center(
          child: FetchDataWidget(),
        ),
      ),
    );
  }
}

class FetchDataWidget extends StatefulWidget {
  const FetchDataWidget({super.key});




  @override
  // ignore: library_private_types_in_public_api


  
  _FetchDataWidgetState createState() => _FetchDataWidgetState();
}

class _FetchDataWidgetState extends State<FetchDataWidget> {
  final List<dynamic> _data = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _offset = 0;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetch();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetch() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/?offset=$_offset&limit=$_limit'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _data.addAll(data['results']);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchMore() async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/?offset=$_offset&limit=$_limit'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        _data.addAll(data['results']);
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
      throw Exception('Failed to load data');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _offset += _limit;
      fetchMore();
    }
  }

  String getPokemonId(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments[segments.length - 2];
  }

  String getPokemonImageUrl(String id) {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isLoading
            ? const CircularProgressIndicator()
            : _data.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _data.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _data.length) {
                          return _isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Container();
                        }
                        var item = _data[index];
                        String id = getPokemonId(item['url']);
                        String imageUrl = getPokemonImageUrl(id);
                        return ListTile(
                          leading: Image.network(
                            imageUrl,
                            height: 80.0,
                            width: 80.0,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['name'],
                              style: const TextStyle(fontSize: 20)),
                        );
                      },
                    ),
                  )
                : const Text('No data'),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
