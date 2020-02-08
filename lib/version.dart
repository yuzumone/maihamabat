import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:args/command_runner.dart';

class Version extends Command {
  @override
  final name = 'version';
  @override
  final description = 'Print version.';

  Version();

  void run() {
    var f = File('./pubspec.yaml');
    var spec = loadYaml(f.readAsStringSync());
    var version = spec['version'];
    print('maihamabat ${version}');
  }
}
