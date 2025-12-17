import 'package:flutter/material.dart';

class SpiceMarketLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const SpiceMarketLogo({
    this.size = 80,
    this.showText = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade600, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Chili Pepper Background
              Icon(
                Icons.local_fire_department,
                size: size * 0.6,
                color: Colors.white,
              ),
              // Brand Circle with Text
              Positioned(
                bottom: size * 0.05,
                right: size * 0.05,
                child: Container(
                  width: size * 0.35,
                  height: size * 0.35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SM',
                      style: TextStyle(
                        fontSize: size * 0.12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: 8),
          Text(
            'Spice Market',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          Text(
            'Premium Spices',
            style: TextStyle(
              fontSize: size * 0.08,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
