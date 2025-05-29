import 'package:flutter/material.dart';

class TokoKuLogo extends StatelessWidget {
  final double size;
  
  const TokoKuLogo({
    Key? key,
    this.size = 200,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/LogoTokoKu.png',
          width: size,
          height: size,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Toko',
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D7BEE),
              ),
            ),
            Text(
              'Ku',
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}