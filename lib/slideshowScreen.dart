import './slideshow.dart';
import 'package:flutter/material.dart';

class SlideshowScreen extends StatelessWidget {
  const SlideshowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slideshow Screen'),
      ),
      body: Stack(
        children: [
          Slideshow(
            autoplay: true,
            autoplayInterval: Duration(milliseconds: 5000),
            animationType: SlideshowAnimationType.Horizontal,
            images: [
              Image.asset(
                'images/slide_1.jpg',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'images/slide_2.jpg',
                fit: BoxFit.cover,
              ),
              Image.asset(
                'images/slide_3.jpg',
                fit: BoxFit.cover,
              ),
              Image.asset('images/slide_4.jpg', fit: BoxFit.cover)
            ],
          )
        ],
      ),
    );
  }
}
