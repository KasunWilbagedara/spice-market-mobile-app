import 'package:flutter/material.dart';
import '../models/spice.dart';

class SpiceCard extends StatelessWidget {
  final Spice spice;
  const SpiceCard({super.key, required this.spice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Expanded(child: Container(color: Colors.orange[100], child: Center(child: Text(spice.name, style: TextStyle(fontSize: 16))))),
        Padding(padding: EdgeInsets.all(8), child: Text('₹${spice.price.toStringAsFixed(2)}')),
      ]),
    );
  }
}
