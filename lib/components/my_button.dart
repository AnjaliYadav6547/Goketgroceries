import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;

  const MyButton({
    super.key, 
    required this.onTap, 
    required this.text,
    this.backgroundColor = Colors.orange, // Changed default
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced
    this.margin = EdgeInsets.zero, // Changed to zero
    this.width,
    this.height,
  });
    
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Added width control
      height: height, // Added height control
      margin: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}