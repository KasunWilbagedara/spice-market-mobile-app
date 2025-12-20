class BillingDetails {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String bankAccountName;
  final String bankAccountNumber;
  final String bankName;
  final String ifscCode;

  BillingDetails({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.bankName,
    required this.ifscCode,
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'bankAccountName': bankAccountName,
        'bankAccountNumber': bankAccountNumber,
        'bankName': bankName,
        'ifscCode': ifscCode,
      };
}

class Order {
  final String id;
  final String buyerId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final BillingDetails billingDetails;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.billingDetails,
    required this.orderDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'buyerId': buyerId,
        'items': items,
        'totalAmount': totalAmount,
        'billingDetails': billingDetails.toMap(),
        'orderDate': orderDate.toIso8601String(),
        'status': status,
      };
}
