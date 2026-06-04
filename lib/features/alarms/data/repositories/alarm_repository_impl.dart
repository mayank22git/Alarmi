import '../../domain/models/alarm_model.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../../../core/services/storage_service.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final StorageService _storageService;

  AlarmRepositoryImpl(this._storageService);

  @override
  List<AlarmModel> getAlarms() {
    return _storageService.getAlarms();
  }

  @override
  Future<void> saveAlarm(AlarmModel alarm) async {
    await _storageService.saveAlarm(alarm);
  }

  @override
  Future<void> deleteAlarm(int id) async {
    await _storageService.deleteAlarm(id);
  }
}
