import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmSelectionNotifier extends StateNotifier<Set<int>> {
  AlarmSelectionNotifier() : super({});

  bool get isSelectionMode => state.isNotEmpty;

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void select(int id) {
    state = {...state, id};
  }

  void clear() {
    state = {};
  }

  bool isSelected(int id) => state.contains(id);
}

final alarmSelectionProvider = StateNotifierProvider<AlarmSelectionNotifier, Set<int>>((ref) {
  return AlarmSelectionNotifier();
});
