import 'package:flutter/cupertino.dart';

String getCurrentRouteName(BuildContext context) {
  return ModalRoute.of(context)?.settings.name ?? '/';
}