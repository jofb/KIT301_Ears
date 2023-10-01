import 'package:logger/logger.dart';

Logger get logger => Log.instance;

class Log extends Logger {
  Log._()
      : super(
            printer: PrettyPrinter(
                printTime: true, printEmojis: false, methodCount: 0));
  static final instance = Log._();
}
