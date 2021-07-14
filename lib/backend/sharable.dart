import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

final ButtonStyle elevatedbutton = ElevatedButton.styleFrom(
  primary: Colors.lime,
  splashFactory: InkRipple.splashFactory,
  elevation: 10,
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(25))),
);
final ButtonStyle textButtonstyle = TextButton.styleFrom(
    textStyle: TextStyle(
  color: Colors.black,
));
