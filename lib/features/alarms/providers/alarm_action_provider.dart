import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/alarm_model.dart';

enum AlarmActionType { add, update, delete, toggle, undo }

class AlarmActionState {
  final AlarmActionType? type;
  final bool success;
  final String? message;
  final AlarmModel? alarm;
  final DateTime? timestamp;

  AlarmActionState({
    this.type,
    this.success = false,
    this.message,
    this.alarm,
    this.timestamp,
  });
}

class AlarmActionNotifier extends StateNotifier<AlarmActionState> {
  AlarmActionNotifier() : super(AlarmActionState());

  void notify(AlarmActionType type, bool success, {String? message, AlarmModel? alarm}) {
    state = AlarmActionState(
      type: type,
      success: success,
      message: message,
      alarm: alarm,
      timestamp: DateTime.now(),
    );
  }
}

final alarmActionProvider = StateNotifierProvider<AlarmActionNotifier, AlarmActionState>((ref) {
  return AlarmActionNotifier();
});
