import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:maihamabat/notify_comingsoon.dart';
import 'package:maihamabat/version.dart';

void main(List<String> arguments) {
  var runner = CommandRunner('maihamabat', 'batch operation for maihama.')
    ..addCommand(NotifyComingsoon())
    ..addCommand(Version())
    ..run(arguments).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64);
    });
}
