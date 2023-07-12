import 'package:flutter/material.dart';
import 'package:portal/commons/theme.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 10),
      child: Text(
        title,
        style: DWTextTypography.of(context)
            .text18bold
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
