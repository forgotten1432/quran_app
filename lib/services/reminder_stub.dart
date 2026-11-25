/// Web: zamanlanmış yerel bildirim yok.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  bool get isSupported => false;

  Future<void> init() async {}

  Future<bool> enable({required int hour, required int minute}) async => false;

  Future<void> disable() async {}
}
