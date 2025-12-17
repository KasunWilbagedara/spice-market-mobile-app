import 'package:flutter/material.dart';
import 'dart:math';

class CategoryCarouselWidget extends StatefulWidget {
  const CategoryCarouselWidget({Key? key}) : super(key: key);

  @override
  State<CategoryCarouselWidget> createState() => _CategoryCarouselWidgetState();
}

class _CategoryCarouselWidgetState extends State<CategoryCarouselWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Spicy', 'icon': Icons.local_fire_department, 'color': Colors.red},
    {'name': 'Mild', 'icon': Icons.spa, 'color': Colors.green},
    {'name': 'Sweet', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Exotic', 'icon': Icons.star, 'color': Colors.purple},
    {'name': 'Premium', 'icon': Icons.diamond, 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pageController = PageController(viewportFraction: 0.6);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rotating Semi-Circle Categories
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Semi-circle background
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(150),
                    topRight: Radius.circular(150),
                  ),
                ),
              ),
              // Rotating Categories
              RotationTransition(
                turns: _rotationController,
                child: SizedBox(
                  width: 280,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(
                      categories.length,
                      (index) {
                        final angle = (index / categories.length) * pi;
                        final radius = 120.0;
                        final x = radius * cos(angle);
                        final y = radius * sin(angle) - 60;

                        return Positioned(
                          left: 140 + x,
                          top: 90 + y,
                          child: AnimatedScale(
                            scale: _currentIndex == index ? 1.2 : 1.0,
                            duration: Duration(milliseconds: 300),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _currentIndex = index);
                              },
                              child: CategoryCircle(
                                category: categories[index],
                                isSelected: _currentIndex == index,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Center dot
              Positioned(
                bottom: 60,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        // Carousel Slider
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategorySliderCard(
                category: categories[index],
                isCenter: _currentIndex == index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryCircle extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;

  const CategoryCircle({
    required this.category,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            category['color'].shade400,
            category['color'].shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: category['color'].withOpacity(0.5),
            blurRadius: isSelected ? 20 : 10,
            spreadRadius: isSelected ? 3 : 1,
          ),
        ],
        border: isSelected
            ? Border.all(
                color: Colors.white,
                width: 3,
              )
            : null,
      ),
      child: Center(
        child: Icon(
          category['icon'],
          color: Colors.white,
          size: isSelected ? 36 : 28,
        ),
      ),
    );
  }
}

class CategorySliderCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isCenter;

  const CategorySliderCard({
    required this.category,
    required this.isCenter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedScale(
        scale: isCenter ? 1.0 : 0.85,
        duration: Duration(milliseconds: 300),
        child: Card(
          elevation: isCenter ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category['color'].shade100,
                  category['color'].shade200,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: isCenter
                  ? Border.all(
                      color: category['color'].shade700,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: category['color'].withOpacity(0.3),
                  ),
                  child: Center(
                    child: Icon(
                      category['icon'],
                      color: category['color'].shade700,
                      size: 28,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isCenter ? 14 : 12,
                    color: category['color'].shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
