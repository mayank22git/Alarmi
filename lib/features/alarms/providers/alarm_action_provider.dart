import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';

enum AlarmActionType { add, update, delete, toggle, undo }

class AlarmActionState {
  final AlarmActionType? type;
  final bool success;
  final String? message;
  final List<AlarmModel> alarms;
  final DateTime? timestamp;

  AlarmActionState({
    this.type,
    this.success = false,
    this.message,
    this.alarms = const [],
    this.timestamp,
  });

  AlarmModel? get alarm => alarms.isNotEmpty ? alarms.first : null;
}

class AlarmActionNotifier extends StateNotifier<AlarmActionState> {
  AlarmActionNotifier() : super(AlarmActionState());

  void notify(AlarmActionType type, bool success, {String? message, List<AlarmModel> alarms = const []}) {
    state = AlarmActionState(
      type: type,
      success: success,
      message: message,
      alarms: alarms,
      timestamp: DateTime.now(),
    );
  }

  void notifySingle(AlarmActionType type, bool success, {String? message, AlarmModel? alarm}) {
    notify(type, success, message: message, alarms: alarm != null ? [alarm] : []);
  }
}

final alarmActionProvider = StateNotifierProvider<AlarmActionNotifier, AlarmActionState>((ref) {
  return AlarmActionNotifier();
});
