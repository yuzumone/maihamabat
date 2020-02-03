import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:maihamabat/api.dart';

import 'api.dart';

class NotifyComingsoon extends Command {
  @override
  final name = 'notify-comingsoon';
  @override
  final description = 'Notify comingsoon item to slack.';

  NotifyComingsoon() {
    argParser.addOption('park',
        abbr: 'p', allowed: ['both', 'tdl', 'tds'], defaultsTo: 'all');
    argParser.addOption('token', abbr: 't', help: 'Slack token');
    argParser.addOption('channel', abbr: 'c', help: 'Slack channel');
    argParser.addOption('bot-username', abbr: 'u', help: 'Slack bot name');
    argParser.addOption('bot-emoji', abbr: 'e', help: 'Slack bot icon');
  }

  void run() async {
    var park = argResults['park'];
    var token = argResults['token'];
    var channel = argResults['channel'];
    var username = argResults['bot-username'];
    var emoji = argResults['bot-emoji'];
    var tdlItems = await getTdlComingsoon();
    var tdsItems = await getTdsComingsoon();
    if (park == 'both') {
      var tmp = [];
      List<Map<String, String>> items = [];
      (tdlItems + tdsItems).forEach((x) {
        if (!tmp.contains(x['link'])) {
          tmp.add(x['link']);
          items.add(x);
        }
      });
      var data = {
        'channel': '#${channel}',
        'username': username,
        'icon_emoji': emoji,
        'attachments': _createAttachments(items),
      };
      var result = await postSlack(token, jsonEncode(data));
    } else if (park == 'tdl') {
      var data = {
        'channel': '#${channel}',
        'username': username,
        'icon_emoji': emoji,
        'attachments': _createAttachments(tdlItems),
      };
      var result = await postSlack(token, jsonEncode(data));
    } else if (park == 'tds') {
      var data = {
        'channel': '#${channel}',
        'username': username,
        'icon_emoji': emoji,
        'attachments': _createAttachments(tdsItems),
      };
      var result = await postSlack(token, jsonEncode(data));
    }
  }

  List<Map<String, String>> _createAttachments(
      List<Map<String, String>> items) {
    return items
        .map((item) => {
              'text': item['price'],
              'title': item['name'],
              'title_link': item['link'],
              'thumb_url': item['img'],
              'footer': item['date']
            })
        .toList();
  }
}
