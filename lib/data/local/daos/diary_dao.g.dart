// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_dao.dart';

// ignore_for_file: type=lint
mixin _$DiaryDaoMixin on DatabaseAccessor<CalviDb> {
  $MealsTable get meals => attachedDatabase.meals;
  $WaterLogsTable get waterLogs => attachedDatabase.waterLogs;
  $WeightsTable get weights => attachedDatabase.weights;
  $WorkoutsTable get workouts => attachedDatabase.workouts;
  DiaryDaoManager get managers => DiaryDaoManager(this);
}

class DiaryDaoManager {
  final _$DiaryDaoMixin _db;
  DiaryDaoManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db.attachedDatabase, _db.meals);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db.attachedDatabase, _db.waterLogs);
  $$WeightsTableTableManager get weights =>
      $$WeightsTableTableManager(_db.attachedDatabase, _db.weights);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db.attachedDatabase, _db.workouts);
}
