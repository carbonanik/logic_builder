import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final Function()? onTap;

  const ToolButton({
    required this.icon,
    this.color,
    this.iconColor,
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
        child: Icon(
          icon,
          color: iconColor ?? Colors.grey[400],
        ),
      ),
    );
  }
}
