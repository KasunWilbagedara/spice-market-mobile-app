bool isEmail(String s) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);

bool isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9.!#$%&'
          "'"
          r'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
      .hasMatch(email);
}

bool isValidPhone(String phone) {
  return RegExp(r'^[0-9]{10,}$')
      .hasMatch(phone.replaceAll(RegExp(r'[^0-9]'), ''));
}
