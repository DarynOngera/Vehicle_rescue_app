

import 'package:flutter/material.dart';

class CommonMethods
{

  displaySnackBar(String messageText, context){
    var snackBar = SnackBar(content: Text(messageText) );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }
}