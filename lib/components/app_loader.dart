import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double? height;
  final double? width;
  const AppLoader({super.key,this.height,this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      color: Colors.transparent,
      child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary),),
    );
  }
}
