import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  final Color color;
  final bool isActive;

  const ColorPicker({super.key, required this.color, required this.isActive});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: widget.isActive ? const Color.fromARGB(255, 187, 187, 187) : Colors.transparent,
      child: CircleAvatar(
        radius: 15,
        backgroundColor: widget.color,
      ),
    );
  }
}
