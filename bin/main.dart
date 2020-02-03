import 'package:args/command_runner.dart';
import 'package:maihamabat/notify_comingsoon.dart';

void main(List<String> arguments) {
  var runner = CommandRunner('maihamabat', 'batch operation for maihama.')
    ..addCommand(NotifyComingsoon())
    ..run(arguments);
}
