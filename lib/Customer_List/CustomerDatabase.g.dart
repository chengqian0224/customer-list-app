// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CustomerDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $CustomerDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $CustomerDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $CustomerDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<CustomerDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorCustomerDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $CustomerDatabaseBuilderContract databaseBuilder(String name) =>
      _$CustomerDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $CustomerDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$CustomerDatabaseBuilder(null);
}

class _$CustomerDatabaseBuilder implements $CustomerDatabaseBuilderContract {
  _$CustomerDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $CustomerDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $CustomerDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<CustomerDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$CustomerDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$CustomerDatabase extends CustomerDatabase {
  _$CustomerDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CustomerDAO? _customerDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Customer` (`id` INTEGER NOT NULL, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `streetAddress` TEXT NOT NULL, `city` TEXT NOT NULL, `province` TEXT NOT NULL, `postalCode` TEXT NOT NULL, `birthYear` INTEGER NOT NULL, `birthMonth` INTEGER NOT NULL, `birthDay` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CustomerDAO get customerDAO {
    return _customerDAOInstance ??= _$CustomerDAO(database, changeListener);
  }
}

class _$CustomerDAO extends CustomerDAO {
  _$CustomerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'Customer',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'streetAddress': item.streetAddress,
                  'city': item.city,
                  'province': item.province,
                  'postalCode': item.postalCode,
                  'birthYear': item.birthYear,
                  'birthMonth': item.birthMonth,
                  'birthDay': item.birthDay
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'streetAddress': item.streetAddress,
                  'city': item.city,
                  'province': item.province,
                  'postalCode': item.postalCode,
                  'birthYear': item.birthYear,
                  'birthMonth': item.birthMonth,
                  'birthDay': item.birthDay
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'Customer',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'streetAddress': item.streetAddress,
                  'city': item.city,
                  'province': item.province,
                  'postalCode': item.postalCode,
                  'birthYear': item.birthYear,
                  'birthMonth': item.birthMonth,
                  'birthDay': item.birthDay
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM Customer',
        mapper: (Map<String, Object?> row) => Customer(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['streetAddress'] as String,
            row['city'] as String,
            row['province'] as String,
            row['postalCode'] as String,
            row['birthYear'] as int,
            row['birthMonth'] as int,
            row['birthDay'] as int));
  }

  @override
  Future<void> insertCustomer(Customer customer) async {
    await _customerInsertionAdapter.insert(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer customer) async {
    await _customerDeletionAdapter.delete(customer);
  }
}
