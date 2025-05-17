import 'package:floor/floor.dart';
import 'package:team5_cst2335_project/Customer_List/Customer.dart';

/// Creates DAO for Customer object
@dao
abstract class CustomerDAO {

  /// Returns a list of all Customer objects from the database
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  /// Adds a new Customer object to the database
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates a Customer object in the database
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a Customer object from the database
  @delete
  Future<void> deleteCustomer(Customer customer);

}