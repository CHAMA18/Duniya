// Native platform detection using dart:io.
import 'dart:io' show Platform;

bool platformIsIOS() => Platform.isIOS;
bool platformIsAndroid() => Platform.isAndroid;
