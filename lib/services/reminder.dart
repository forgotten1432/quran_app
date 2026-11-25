/// Günlük okuma hatırlatması. Web'de desteklenmez (no-op).
library;

export 'reminder_stub.dart' if (dart.library.io) 'reminder_native.dart';
