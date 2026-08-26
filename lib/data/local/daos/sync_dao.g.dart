// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncDaoMixin on DatabaseAccessor<CalviDb> {
  $MealsTable get meals => attachedDatabase.meals;
  $WaterLogsTable get waterLogs => attachedDatabase.waterLogs;
  $WeightsTable get weights => attachedDatabase.weights;
  $MeasurementsTable get measurements => attachedDatabase.measurements;
  $WorkoutsTable get workouts => attachedDatabase.workouts;
  $MedicationsTable get medications => attachedDatabase.medications;
  $MedicationTakesTable get medicationTakes => attachedDatabase.medicationTakes;
  $AllergiesTable get allergies => attachedDatabase.allergies;
  $ProfileTable get profile => attachedDatabase.profile;
  $ChatMessagesTable get chatMessages => attachedDatabase.chatMessages;
  $TokenStateTable get tokenState => attachedDatabase.tokenState;
  $SyncMetaTable get syncMeta => attachedDatabase.syncMeta;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db.attachedDatabase, _db.meals);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db.attachedDatabase, _db.waterLogs);
  $$WeightsTableTableManager get weights =>
      $$WeightsTableTableManager(_db.attachedDatabase, _db.weights);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db.attachedDatabase, _db.measurements);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db.attachedDatabase, _db.workouts);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db.attachedDatabase, _db.medications);
  $$MedicationTakesTableTableManager get medicationTakes =>
      $$MedicationTakesTableTableManager(
        _db.attachedDatabase,
        _db.medicationTakes,
      );
  $$AllergiesTableTableManager get allergies =>
      $$AllergiesTableTableManager(_db.attachedDatabase, _db.allergies);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db.attachedDatabase, _db.profile);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db.attachedDatabase, _db.chatMessages);
  $$TokenStateTableTableManager get tokenState =>
      $$TokenStateTableTableManager(_db.attachedDatabase, _db.tokenState);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db.attachedDatabase, _db.syncMeta);
}
