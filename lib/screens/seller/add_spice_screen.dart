import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/spice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/spice.dart';

class AddSpiceScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final spiceProvider = Provider.of<SpiceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Add Spice')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Spice Name')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final sellerId = auth.user?.id ?? '';
                final spice = Spice(
                  id: Uuid().v4(),
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                  sellerId: sellerId,
                );
                await spiceProvider.addSpice(spice);
                Navigator.pop(context);
              },
              child: Text('Add Spice'),
            ),
          ],
        ),
      ),
    );
  }
}
