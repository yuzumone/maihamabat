import 'package:intl/intl.dart';
import 'package:puppeteer/puppeteer.dart';
import 'package:args/command_runner.dart';

class ReservationRestaurant extends Command {
  @override
  final name = 'restaurant';
  @override
  final description = 'Auto restaurant reservation.';
  final baseUrl = 'https://reserve.tokyodisneyresort.jp';
  final failedUrl = 'http://reserve.tokyodisneyresort.jp/fo/index.html';

  ReservationRestaurant() {
    argParser.addOption('name', abbr: 'n', help: 'Restaurant name', allowed: [
      'RESC0',
      'RBBY0',
      'RJRH0',
      'RCPR0',
      'RSSD0',
      'RMGL0',
      'RRDC0',
      'RJRS0',
      'RHZB0',
      'RCHM0',
      'REPG0',
      'ROCE0',
      'ROCE1',
      'RSRG0',
      'RBVL0',
      'RBVL1',
      'RSWG0',
      'RCAN0',
      'RCAN0',
    ], allowedHelp: {
      'RESC0': 'Eastside Cafe',
      'RBBY0': 'Blue Bayou Restaurant',
      'RJRH0': 'Restaurant Hokusai',
      'RCPR0': 'Crystal Palace Restaurant',
      'RSSD0': 'S.S. Columbia Dining Room',
      'RMGL0': 'Magellan\'s',
      'RRDC0': 'Ristorante di Canaletto',
      'RJRS0': 'Restaurant Sakura',
      'RHZB0': 'Horizon Bay Restaurant',
      'RCHM0': 'Chef Mickey',
      'REPG0': 'Empire Grill',
      'ROCE0': 'Oceano (buffet)',
      'ROCE1': 'Oceano (table service)',
      'RSRG0': 'Silk Road Garden',
      'RBVL0': 'BellaVista Lounge',
      'RBVL1': 'BellaVista Lounge (Wall Side)',
      'RSWG0': 'Sherwood Garden Restaurant',
      'RCAN0': 'Canna',
    });
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
    var adaltNum = argResults['adalt-num'] ?? 1;
    var childNum = argResults['child-num'] ?? 0;
    var date =
        argResults['date'] ?? DateFormat('yyyyMMdd').format(DateTime.now());
    var time = argResults['time'];
    if (restaurantName == null) {
      printUsage();
      return null;
    }
    while (true) {
      try {
        await reserve(restaurantName, adaltNum, childNum, date, time);
        break;
      } catch (TimeoutException) {
        print('Timeout: retry...');
      }
    }
  }

  void reserve(
    String restaurantName,
    int adaltNum,
    int childNum,
    String date,
    String time,
  ) async {
    var browser = await puppeteer.launch(headless: false);
    var page = await browser.newPage();
    await page.goto('${baseUrl}/top/', wait: Until.networkIdle);
    while (true) {
      var url =
          '${baseUrl}/restaurant/search/?useDate=${date}&adultNum=${adaltNum}&childNum=${childNum}'
          '&childAgeInform=&nameCd=${restaurantName}&wheelchairCount=0&stretcherCount=0&keyword='
          '&reservationStatus=0';
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
      var reservationAble =
          await page.$$('ul.hiddenFullValue > li.reservationAble');
      if (reservationAble.isEmpty) {
        print('Already full book.');
        return null;
      } else if (time == 'unspecified') {
        return null;
      } else if (time == null || time == 'first') {
        var t = await reservationAble[0]
            .$eval('p.time', 'function (e) { return e.textContent; }');
        time = t.toString().trim();
      }
      for (var item in reservationAble) {
        var t = await item.$eval(
            'p.time', 'function (e) { return e.textContent; }');
        if (t.toString().trim() == time) {
          await item.evaluate('(doc) => doc.querySelector(\'a\').click()');
          break;
        }
      }
      await page.waitForNavigation();
      var afterUrl = await page.url;
      if (afterUrl == '${baseUrl}/online/restaurant/input/') {
        print('Automation finish!!!');
        return null;
      } else {
        print('Failed Page: continue...');
      }
    }
  }
}
