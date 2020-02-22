import 'package:intl/intl.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:args/command_runner.dart';

class ReservationShowRestaurant extends Command {
  @override
  final name = 'show-restaurant';
  @override
  final description = 'Auto show restaurant reservation.';
  final baseUrl = 'https://reserve.tokyodisneyresort.jp';
  final failedUrl = 'http://reserve.tokyodisneyresort.jp/fo/index.html';
  final shows = {
    'RDHS0': 'ホースシュー・ラウンドアップ',
    'RDHS1': 'ザ・ダイヤモンドホースシュー・プレゼンツ“ミッキー＆カンパニー”',
    'RPLT0': 'リロのルアウ＆ファン',
    'RPLT1': 'ミッキーのレインボー・ルアウ',
  };

  ReservationShowRestaurant() {
    argParser.addOption('name', abbr: 'n', help: 'Show name', allowed: [
      'RDHS0',
      'RDHS1',
      'RPLT0',
      'RPLT1',
    ], allowedHelp: {
      'RDHS0': 'Horseshoe Roundup',
      'RDHS1': 'The Diamond Horseshoe Presents Mickey & Company',
      'RPLT0': 'Lilo\'s Luau & Fun',
      'RPLT1': 'Mickey\'s Rainbow Luau',
    });
    argParser.addOption('rank', abbr: 'r', help: 'Seat rank', allowed: [
      'S',
      'A',
      'B',
    ]);
    argParser.addOption('adalt-num',
        abbr: 'a', help: 'Adalt number default: 1');
    argParser.addOption('child-num',
        abbr: 'c', help: 'Child number default: 0');
    argParser.addOption('date',
        abbr: 'd', help: 'Reservation date(yyyyMMdd) default: today');
    var timeHelp = 'Reservation time(HH:MM) default: first\n'
        'first: Reserve at first available time.\n'
        'unspecified: Display reservation page only.';
    argParser.addOption('time', abbr: 't', help: timeHelp);
  }

  @override
  void run() async {
    var restaurantName = argResults['name'];
    var rank = argResults['rank'];
    var adaltNum = argResults['adalt-num'] ?? 1;
    var childNum = argResults['child-num'] ?? 0;
    var date =
        argResults['date'] ?? DateFormat('yyyyMMdd').format(DateTime.now());
    var time = argResults['time'];
    if (restaurantName == null || rank == null) {
      printUsage();
      return null;
    }
    var browser = await puppeteer.launch(headless: false);
     while (true) {
      try {
        await reserve(browser, restaurantName, rank, adaltNum, childNum, date, time);
        break;
      } catch (e) {
        print('Timeout: retry...');
      }
    }
  }

  void reserve(
    Browser browser,
    String restaurantName,
    String rank,
    int adaltNum,
    int childNum,
    String date,
    String time,
  ) async {
    var page = await browser.newPage();
    await page.goto('${baseUrl}/top/');
    while (true) {
      var url =
          '${baseUrl}/showrestaurant/search/list?useDate=${date}&adultNum=${adaltNum}&childNum=${childNum}'
          '&wheelchairCount=0&stretcherCount=0&freeword=&childAgeInform=&reservationStatus=0';
      var res = await page.goto(url, wait: Until.networkIdle);
      if (!res.ok || res.url == failedUrl) {
        print('Failed Page: continue...');
        continue;
      }
      var caution = await page.$('.close02');
      if (caution != null) {
        var close = await caution.$('a');
        await close.click();
      }
      var hasGotReservation = await page.$$('div.hasGotReservation');
      var availableShows = await page.$$eval(
          'div.hasGotReservation > div.header > h3.heading',
          'heading => heading.map(e => e.textContent)');
      availableShows = availableShows.map((e) => e.trim()).toList();
      if (hasGotReservation.isEmpty ||
          !availableShows.contains(shows[restaurantName])) {
        print('Already full book.');
        return null;
      } else if (time == 'unspecified') {
        return null;
      }
      for (var item in hasGotReservation) {
        var title = await item.$eval(
            'h3.heading', 'function (e) { return e.textContent; }');
        if (title.trim() == shows[restaurantName]) {
          var seatLine = await item.$$('.seatLine');
          for (var seat in seatLine) {
            var seatRank = await seat.$eval('.seatRank', 'e => e.value');
            var reservationAble = await seat.$$('li.reservationAble');
            if (reservationAble.isNotEmpty) {
              var t = await reservationAble[0]
                  .$eval('p.time', 'function (e) { return e.textContent; }');
              time = t.trim();
            }
            if (seatRank == rank && reservationAble.isEmpty) {
              print('Already full book.');
              return null;
            } else if (seatRank == rank && reservationAble.isNotEmpty) {
              for (var item in reservationAble) {
                var t = await item.$eval(
                    'p.time', 'function (e) { return e.textContent; }');
                if (t.trim() == time) {
                  await item
                      .evaluate('(doc) => doc.querySelector(\'a\').click()');
                  break;
                }
              }
            }
          }
        }
        await page.waitForNavigation();
        var afterUrl = await page.url;
        if (afterUrl == '${baseUrl}/online/showrestaurant/input/') {
          print('Automation finish!!!');
          return null;
        } else {
          print('Failed Page: continue...');
        }
      }
    }
  }
}
