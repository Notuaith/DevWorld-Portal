import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CustomRiveLoader extends StatelessWidget {
  final bool isWhite;
  final double? width;
  final double? height;
  const CustomRiveLoader(
      {Key? key, required this.isWhite, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width ?? 150,
        height: height ?? 150,
        child: isWhite
            ? RiveAnimation.asset('lib/resources/images/mimmo.riv')
            : RiveAnimation.asset(
                'lib/resources/images/loader.riv',
              ),
      ),
    );
  }
}
