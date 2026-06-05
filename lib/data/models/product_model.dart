class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"] as int,
      title: json["title"] as String,
      price: (json["price"] as num).toDouble(),
      description: (json["description"] as String?) ?? '',
      image: (json["thumbnail"] as String?) ?? (json["image"] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "price": price,
      "description": description,
      "thumbnail": image,
    };
  }
}