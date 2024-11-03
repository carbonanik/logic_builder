import 'package:flutter/material.dart';

class ComponentButton extends StatelessWidget {
  final String name;
  final Color? color;
  final Color? textColor;
  final Function()? onTap;

  const ComponentButton({
    required this.name,
    this.color,
    this.textColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: color ?? Colors.grey[800],
        child: Text(
          name,
          style: TextStyle(
            color: textColor ?? Colors.grey[400],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
