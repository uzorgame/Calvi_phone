// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_dao.dart';

// ignore_for_file: type=lint
mixin _$DiaryDaoMixin on DatabaseAccessor<CalviDb> {
  $MealsTable get meals => attachedDatabase.meals;
  $WaterLogsTable get waterLogs => attachedDatabase.waterLogs;
  $WeightsTable get weights => attachedDatabase.weights;
  $GoalsTable get goals => attachedDatabase.goals;
  $MeasurementsTable get measurements => attachedDatabase.measurements;
  $WorkoutsTable get workouts => attachedDatabase.workouts;
  $MedicationTakesTable get medicationTakes => attachedDatabase.medicationTakes;
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
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db.attachedDatabase, _db.measurements);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db.attachedDatabase, _db.workouts);
  $$MedicationTakesTableTableManager get medicationTakes =>
      $$MedicationTakesTableTableManager(
        _db.attachedDatabase,
        _db.medicationTakes,
      );
}
