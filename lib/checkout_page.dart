import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();

  String deliveryMethod = "pickup";
  String branch = "Beirut";
  String paymentMethod = "usd";

  final double exchangeRate = 89600;
  bool isSubmitting = false;

  Future<void> placeOrder() async {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill name and phone")),
      );
      return;
    }

    if (deliveryMethod == "delivery" && addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter delivery address")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final items = Cart.items.map((e) {
      return {"id": e.id, "name": e.name, "qty": e.qty, "price": e.price};
    }).toList();

    final totalUSD = Cart.total;
    final totalLBP = (totalUSD * exchangeRate).round();

    final body = {
      "fullName": nameCtrl.text,
      "mobile": phoneCtrl.text,
      "address": deliveryMethod == "delivery" ? addressCtrl.text : "",
      "deliveryMethod": deliveryMethod,
      "branch": deliveryMethod == "pickup" ? branch : "",
      "payment": paymentMethod,
      "totalUSD": totalUSD,
      "totalLBP": totalLBP,
      "items": items,
    };

    try {
      final response = await http.post(
        Uri.parse("http://mohamadmarket.atwebpages.com/htdocs/order.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result["success"] == true) {
        Cart.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Order submitted successfully ✅"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuccessPage()),
          );
        }
      } else {
        throw Exception("Order not saved");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final totalUSD = Cart.total;
    final totalLBP = (totalUSD * exchangeRate).round();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Delivery Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    RadioListTile(
                      title: const Text("Pickup"),
                      value: "pickup",
                      groupValue: deliveryMethod,
                      onChanged: (v) => setState(() => deliveryMethod = v!),
                    ),
                    RadioListTile(
                      title: const Text("Delivery"),
                      value: "delivery",
                      groupValue: deliveryMethod,
                      onChanged: (v) => setState(() => deliveryMethod = v!),
                    ),

                    if (deliveryMethod == "pickup")
                      DropdownButtonFormField<String>(
                        initialValue: branch,
                        decoration: const InputDecoration(
                          labelText: "Select Branch",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Beirut",
                            child: Text("Beirut"),
                          ),
                          DropdownMenuItem(
                            value: "Saida",
                            child: Text("Saida"),
                          ),
                          DropdownMenuItem(value: "Tyre", child: Text("Tyre")),
                        ],
                        onChanged: (v) => setState(() => branch = v!),
                      ),

                    if (deliveryMethod == "delivery")
                      TextField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(
                          labelText: "Delivery Address",
                        ),
                      ),

                    const SizedBox(height: 20),

                    const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    RadioListTile(
                      title: const Text("Cash (USD)"),
                      value: "usd",
                      groupValue: paymentMethod,
                      onChanged: (v) => setState(() => paymentMethod = v!),
                    ),
                    RadioListTile(
                      title: const Text("Cash (LBP)"),
                      value: "lbp",
                      groupValue: paymentMethod,
                      onChanged: (v) => setState(() => paymentMethod = v!),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total (USD):"),
                        Text("\$${totalUSD.toStringAsFixed(2)}"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total (LBP):"),
                        Text("$totalLBP LBP"),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : placeOrder,
                        child: Text(
                          isSubmitting ? "Processing..." : "Place Order",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
