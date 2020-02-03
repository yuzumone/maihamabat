import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class TDRClient extends http.BaseClient {
  final http.Client _client;
  TDRClient(this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] =
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36';
    request.headers['Accept'] =
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8';
    request.headers['Accept-Encoding'] = 'gzip, deflate, br';
    request.headers['Accept-Language'] = 'ja';
    request.headers['Upgrade-Insecure-Requests'] = '1';
    request.headers['Connection'] = 'keep-alive';
    return _client.send(request);
  }
}

Future<List<Map<String, String>>> getTdlComingsoon() async {
  var url =
      'https://www.tokyodisneyresort.jp/view_interface.php?blockId=94199&pageBlockId=2084564';
  var client = TDRClient(http.Client());
  var res = await client.get(url);
  var doc = parse(res.body);
  return doc
      .querySelectorAll('li')
      .map((item) => {
            'img': item.querySelector('img').attributes['src'],
            'link':
                "https://www.tokyodisneyresort.jp${item.querySelector('a').attributes['href']}",
            'name': item.querySelector('.linkText').text,
            'price': item.querySelector('.price').text,
            'date': item.querySelectorAll('p')[2].text,
          })
      .toList();
}

Future<List<Map<String, String>>> getTdsComingsoon() async {
  var url =
      'https://www.tokyodisneyresort.jp/view_interface.php?blockId=94199&pageBlockId=2084606';
  var client = TDRClient(http.Client());
  var res = await client.get(url);
  var doc = parse(res.body);
  return doc
      .querySelectorAll('li')
      .map((item) => {
            'img': item.querySelector('img').attributes['src'],
            'link':
                "https://www.tokyodisneyresort.jp${item.querySelector('a').attributes['href']}",
            'name': item.querySelector('.linkText').text,
            'price': item.querySelector('.price').text,
            'date': item.querySelectorAll('p')[2].text,
          })
      .toList();
}

Future<http.Response> postSlack(String token, String json) {
  var client = http.Client();
  return client.post('https://slack.com/api/chat.postMessage',
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer ${token}'
      },
      body: json);
}
