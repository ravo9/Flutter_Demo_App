class Article {
  final String title;
  final String imageUrl;

  Article({required this.title, required this.imageUrl});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['data']['title'] as String,
      imageUrl: json['data']['thumbnail'] as String,
    );
  }
}