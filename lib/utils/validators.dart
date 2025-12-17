bool isEmail(String s) => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);
