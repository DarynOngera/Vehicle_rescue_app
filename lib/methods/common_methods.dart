
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if(!context.mounted) return;
      displaySnackBar("Check Internet Connection", context);

    }

  }
  displaySnackBar(String messageText, context){
    var snackBar = SnackBar(content: Text(messageText) );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
  }
}