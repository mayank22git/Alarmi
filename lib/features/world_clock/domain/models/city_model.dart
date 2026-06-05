import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'city_model.g.dart';

@HiveType(typeId: 1)
class CityModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String timezone;

  const CityModel({
    required this.id,
    required this.name,
    required this.timezone,
  });

  @override
  List<Object?> get props => [id, name, timezone];
}
