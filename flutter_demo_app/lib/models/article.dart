class Article {
  final String title;
  final String imageUrl;
  final String url;  // Add this line

  Article({required this.title, required this.imageUrl, required this.url}); // Update this line

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['data']['title'] as String,
      imageUrl: json['data']['thumbnail'] as String,
      url: json['data']['url'] as String, // Add this line
    );
  }
}
