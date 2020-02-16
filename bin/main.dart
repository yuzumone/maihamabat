import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:maihamabat/notify_comingsoon.dart';
import 'package:maihamabat/version.dart';
import 'package:maihamabat/reservation.dart';

void main(List<String> arguments) {
  var version = Version();
  var runner = CommandRunner('maihamabat', 'batch operation for maihama.');
  runner
    ..argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: version.description,
      callback: (flag) {
        if (flag) {
          runner.run(['version']);
          exit(0);
        }
      },
    )
    ..addCommand(NotifyComingsoon())
    ..addCommand(version)
    ..addCommand(Reservation())
    ..run(arguments).catchError(
      (error) {
        if (error is! UsageException) throw error;
        print(error);
        exit(64);
      },
    );
}
