import 'package:args/command_runner.dart';
import 'package:maihamabat/reservation_restaurant.dart';
import 'package:maihamabat/reservation_show_restaurant.dart';

class Reservation extends Command {
  @override
  final name = 'reservation';
  @override
  final description = 'Auto reservation.';

  Reservation() {
    addSubcommand(ReservationRestaurant());
    addSubcommand(ReservationShowRestaurant());
  }
}
