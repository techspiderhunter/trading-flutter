
import 'package:intl/intl.dart';


String formatDate(String date) {
  final DateTime parsed = DateTime.parse(date).toLocal();
  return DateFormat('yyyy-MM-dd').format(parsed);
}
