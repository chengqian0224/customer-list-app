import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:team5_cst2335_project/Customer_List/Customer.dart';
import 'CustomerDAO.dart';

part 'CustomerDatabase.g.dart';

/// Creates database for Customer entity
@Database(version:1, entities: [Customer])
abstract class CustomerDatabase extends FloorDatabase {
  /// Returns DAO for interact with the database in the app
  CustomerDAO get customerDAO;
}