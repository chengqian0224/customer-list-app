import 'package:floor/floor.dart';

@entity
class Customer {
  static int ID = 1;

  @primaryKey
  final int id;

  /// First name of the Customer
  final String firstName;

  /// Last name of the Customer
  final String lastName;

  /// Street address of the Customer
  final String streetAddress;

  /// City of the Customer
  final String city;

  /// Province of the Customer
  final String province;

  /// Postal code of the Customer
  final String postalCode;

  /// Year of the Customer
  final int birthYear;

  /// Month of birth of the Customer
  final int birthMonth;

  /// Day of birth of the Customer
  final int birthDay;

  /// Constructor of an Customer object
  Customer(this.id, this.firstName, this.lastName,
      this.streetAddress, this.city, this.province, this.postalCode,
      this.birthYear, this.birthMonth, this.birthDay){
    if (id > ID) {
      ID = id + 1;
    }
  }
}