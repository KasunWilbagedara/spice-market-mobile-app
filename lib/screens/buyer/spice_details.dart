import 'package:flutter/material.dart';
import '../../models/spice.dart';

class SpiceDetails extends StatelessWidget {
  final Spice spice;

  const SpiceDetails({super.key, required this.spice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spice.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${spice.name}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Price: \$${spice.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Category: ${spice.category ?? 'N/A'}'),
            SizedBox(height: 10),
            Text('Description: ${spice.description ?? 'No description'}'),
          ],
        ),
      ),
    );
  }
}
