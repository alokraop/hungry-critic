import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'config.dart';

class Aspects {
  static late AppConfig config;

  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  static Aspects? _instance;

  static Aspects get instance => _instance ?? _fetch();

  static Aspects _fetch() => _instance = Aspects._();

  Aspects._();

  static init(AppConfig c) => config = c;

  Future recordError(exception, [StackTrace? stack]) async {
    logger.e(exception.toString(), exception, stack);
    debugPrintStack(stackTrace: stack);
  }

  Future recordLogin(String method) async {
    logger.i('Logged in: $method');
  }

  void log(String message, [Level level = Level.verbose]) {
    logger.log(level, message);
  }
}
