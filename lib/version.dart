import 'dart:io';
import 'package:args/command_runner.dart';

class Version extends Command {
  @override
  final name = 'version';
  @override
  final description = 'Print version.';
  final String VERSION = 'v0.0.2';

  Version();

  void run() {
    print('maihamabat: ${VERSION}');
    print('Dart ${Platform.version}');
  }
}
