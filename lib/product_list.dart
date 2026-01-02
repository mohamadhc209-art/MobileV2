import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'cart_page.dart';

class ProductListPage extends StatefulWidget {
  final String categoryName;

  const ProductListPage({super.key, required this.categoryName});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<dynamic>> _productsFuture;

  final Map<int, int> quantities = {};

  final Color primaryBlue = const Color(0xFF1565C0);
  final Color lightBlue = const Color(0xFFE3F2FD);

  Future<List<dynamic>> getProducts() async {
    final url =
        "http://mohamadmarket.atwebpages.com/htdocs/products.php?category=${widget.categoryName}";
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading products"));
          }

          final products = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                quantities[index] ??= 1;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          product["image"],
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        product["name"],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "\$${product["price"]}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: primaryBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                if (quantities[index]! > 1) {
                                  quantities[index] = quantities[index]! - 1;
                                }
                              });
                            },
                          ),
                          Text(
                            quantities[index].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: primaryBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                quantities[index] = quantities[index]! + 1;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            Cart.addItem(
                              CartItem(
                                id: product["id"],
                                name: product["name"],
                                price: double.parse(
                                  product["price"].toString(),
                                ),
                                image: product["image"],
                                qty: quantities[index]!,
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Added ${quantities[index]} × ${product["name"]}",
                                ),
                                duration: const Duration(milliseconds: 800),
                                backgroundColor: primaryBlue,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
