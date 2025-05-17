import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../main.dart';
import '../AppLocalizations.dart';
import 'Customer.dart';
import 'CustomerDAO.dart';
import 'CustomerDatabase.dart';

/// Page for Customer List
class CustomerListPage extends StatefulWidget {

  @override
  State<CustomerListPage> createState() => CustomerListState();
}

class CustomerListState extends State<CustomerListPage> {

  /// The list of all customers fetched from the database
  List<Customer> customerList = <Customer>[];

  /// Text input controller for first name
  late TextEditingController _firstNameController;

  /// Text input controller for larst name
  late TextEditingController _lastNameController;

  /// Text input controller for street address
  late TextEditingController _streetAddressController;

  /// Text input controller for city
  late TextEditingController _cityController;

  /// Text input controller for province
  late TextEditingController _provinceController;

  /// Text input controller for postal code
  late TextEditingController _postalCodeController;

  /// Text input controller for year of birth
  late TextEditingController _birthYearController;

  /// Text input controller for month of birth
  late TextEditingController _birthMonthController;

  /// Text input controller for day of birth
  late TextEditingController _birthDayController;

  /// Data Access Object for performing CRUD operations on Customer database
  late CustomerDAO customerDAO;

  /// Currently selected customer for editing
  Customer? selectedCustomer;

  /// Encrypted shared preferences used to save the last added customer's data
  EncryptedSharedPreferences encryptedPrefs = EncryptedSharedPreferences();

  /// Whether the user is currently adding a new customer.
  bool adding = false;

  /// Whether the user is currently editing an existing customer.
  bool editing = false;

  /// Initializes the state by loading all customers from the database
  /// and preparing all input controllers.
  @override
  void initState(){
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _streetAddressController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _postalCodeController = TextEditingController();
    _birthYearController = TextEditingController();
    _birthMonthController = TextEditingController();
    _birthDayController = TextEditingController();

    $FloorCustomerDatabase
        .databaseBuilder('customer_database.db').build().then((database) async {
      customerDAO = database.customerDAO;

      /// store a customer list got from the DAO
      var cl = await customerDAO.getAllCustomers();
      setState(() {
        customerList = cl;
      });
    });
  }

  /// Disposes all text editing controllers when the widget is removed from the tree
  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _birthYearController.dispose();
    _birthMonthController.dispose();
    _birthDayController.dispose();
  }

  /// Clears all input fields in the customer form
  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _streetAddressController.clear();
    _cityController.clear();
    _provinceController.clear();
    _postalCodeController.clear();
    _birthYearController.clear();
    _birthMonthController.clear();
    _birthDayController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate("customerListTitle")!),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              tooltip: AppLocalizations.of(context)!.translate("instructionCustomerList")!,
              onPressed: displayInstructions,
            ),
            OutlinedButton(child:Text("EN") , onPressed: (){  MyApp.setLocale(context, Locale('en','CA') );} ),
            OutlinedButton(child:Text("FR") , onPressed: (){  MyApp.setLocale(context, Locale('fr','FR') );} ),
          ],
        ),
        body: reactiveLayout()
    );
  }

  /// Returns the appropriate layout depending on screen orientation
  Widget reactiveLayout() {
    /// Stores size of the screen
    var size = MediaQuery.sizeOf(context);

    /// Stores height of the screen
    var height = size.height;

    /// Stores width of the screen
    var width = size.width;

    if ((width > height) && (width > 720)) {
      // Landscape
      return Row(children: [
        Expanded(flex: 1, child: listPage()),
        Expanded(flex: 2, child: detailsPage())
      ]);
    } else {
      // Portrait
      if ((selectedCustomer == null) && (adding == false))
        return listPage();
      else {
        return detailsPage();
      }
    }
  }

  /// Builds the page for the main list
  Widget listPage() {
    return Column (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: (){
              showDialog(
                context: context,
                builder: (BuildContext context) => copyFromPreviousCustomer(context),
              );
            },
            child: Text(AppLocalizations.of(context)!.translate("addCustomer")!),
          ),
          Expanded(
              child:
              customerList.isEmpty ? Text(AppLocalizations.of(context)!.translate("noCustomer")!) :
              ListView.builder(
                  itemCount: customerList.length,
                  itemBuilder: (conext, rowNum) {
                    return GestureDetector(
                        onTap: () {
                          setState((){
                            selectedCustomer = customerList[rowNum];
                            editing = true;
                          });
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(width: 20),
                              Text(
                                "${customerList[rowNum].firstName} ${customerList[rowNum].lastName}",
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ])
                    );
                  }
              )
          )
        ]
    );
  }

  /// Builds the page for the customer's detail page
  Widget detailsPage() {
    TextStyle mystyle = TextStyle(fontSize: 32.0);
    if (adding) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: customerForm(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    adding = false;
                  });
                },
                child: Text(AppLocalizations.of(context)!.translate("cancel")!),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: addCustomer,
                child: Text(AppLocalizations.of(context)!.translate("submit")!),
              ),
            ],
          ),
        ],
      );

    } else if (editing) {
      _firstNameController.text = selectedCustomer!.firstName;
      _lastNameController.text = selectedCustomer!.lastName;
      _streetAddressController.text = selectedCustomer!.streetAddress;
      _cityController.text = selectedCustomer!.city;
      _provinceController.text = selectedCustomer!.province;
      _postalCodeController.text = selectedCustomer!.postalCode;
      _birthYearController.text = selectedCustomer!.birthYear.toString();
      _birthMonthController.text = selectedCustomer!.birthMonth.toString();
      _birthDayController.text = selectedCustomer!.birthDay.toString();
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: customerForm(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _clearForm();
                  setState(() {
                    editing = false;
                    selectedCustomer = null;
                  });
                },
                child: Text(AppLocalizations.of(context)!.translate("cancel")!),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: editCustomer,
                child: Text(AppLocalizations.of(context)!.translate("update")!),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: removeCustomer,
                child: Text("Delete"),
              ),
            ],
          ),
        ],
      );

    } else if (selectedCustomer == null) {
      return Text(AppLocalizations.of(context)!.translate("selectToView")!, style: mystyle);
    } else {
      return SizedBox(); // Fallback
    }
  }

  /// Returns the form widget used for entering or editing customer details
  Widget customerForm() {
    return Padding (
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppLocalizations.of(context)!.translate("name")!),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("firstName")!,
                      labelText: AppLocalizations.of(context)!.translate("firstName")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("lastName")!,
                      labelText: AppLocalizations.of(context)!.translate("lastName")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.translate("address")!),
            Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _streetAddressController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate("streetAddress")!,
                        labelText: AppLocalizations.of(context)!.translate("streetAddress")!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ]),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("city")!,
                      labelText: AppLocalizations.of(context)!.translate("city")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _provinceController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("province")!,
                      labelText: AppLocalizations.of(context)!.translate("province")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("postalCode")!,
                      labelText: AppLocalizations.of(context)!.translate("postalCode")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.translate("birthday")!),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _birthYearController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("year")!,
                      labelText: AppLocalizations.of(context)!.translate("year")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _birthMonthController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("month")!,
                      labelText: AppLocalizations.of(context)!.translate("month")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _birthDayController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.translate("day")!,
                      labelText: AppLocalizations.of(context)!.translate("day")!,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  /// Adds a new customer
  void addCustomer() {
    if (_validateForm()) {
      setState(() {
        /// Stores the new customer object to be added
        var newCustomer = Customer(
            Customer.ID++,
            _firstNameController.text,
            _lastNameController.text,
            _streetAddressController.text,
            _cityController.text,
            _provinceController.text,
            _postalCodeController.text,
            int.parse(_birthYearController.text),
            int.parse(_birthMonthController.text),
            int.parse(_birthDayController.text)
        );
        customerList.add(newCustomer);
        customerDAO.insertCustomer(newCustomer);
        saveCustomerToPrefs(newCustomer);
        _clearForm();
        adding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate("customerAdded") ?? ''))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate("inputRequired") ?? ''))
      );
    }
  }


  /// Saves the latest customer info to EncryptedSharedPreferences
  Future<void> saveCustomerToPrefs(Customer customer) async {
    await encryptedPrefs.setString("savedFirstName", customer.firstName);
    await encryptedPrefs.setString("savedLastName", customer.lastName);
    await encryptedPrefs.setString("savedStreetAddress", customer.streetAddress);
    await encryptedPrefs.setString("savedCity", customer.city);
    await encryptedPrefs.setString("savedProvince", customer.province);
    await encryptedPrefs.setString("savedPostalCode", customer.postalCode);
    await encryptedPrefs.setString("savedBirthYear", customer.birthYear.toString());
    await encryptedPrefs.setString("savedBirthMonth", customer.birthMonth.toString());
    await encryptedPrefs.setString("savedBirthDay", customer.birthDay.toString());
  }

  /// Loads the last saved customer data from EncryptedSharedPreferences
  Future<void> loadCustomerToPrefs() async {
    _firstNameController.text = await encryptedPrefs.getString("savedFirstName") ?? '';
    _lastNameController.text = await encryptedPrefs.getString("savedLastName") ?? '';
    _streetAddressController.text = await encryptedPrefs.getString("savedStreetAddress") ?? '';
    _cityController.text = await encryptedPrefs.getString("savedCity") ?? '';
    _provinceController.text = await encryptedPrefs.getString("savedProvince") ?? '';
    _postalCodeController.text = await encryptedPrefs.getString("savedPostalCode") ?? '';
    _birthYearController.text = await encryptedPrefs.getString("savedBirthYear") ?? '';
    _birthMonthController.text = await encryptedPrefs.getString("savedBirthMonth") ?? '';
    _birthDayController.text = await encryptedPrefs.getString("savedBirthDay") ?? '';
  }

  /// Asks the user whether to copy the previous customer's information
  AlertDialog copyFromPreviousCustomer(BuildContext context) {
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("CopyCustomerDialogTitle")!),
        content: Text(AppLocalizations.of(context)!.translate("CopyCustomerDialogContent")!),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                loadCustomerToPrefs().then((_) {
                  setState(() {
                    adding = true;
                  });
                });
              },
              child: Text(AppLocalizations.of(context)!.translate("CopyOption")!)
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
                setState(() {
                  adding = true;
                });
              },
              child: Text(AppLocalizations.of(context)!.translate("BlankOption")!)
          ),
        ]
    );
  }

  /// Validate all input fields are not empty
  bool _validateForm() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _streetAddressController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _provinceController.text.trim().isNotEmpty &&
        _postalCodeController.text.trim().isNotEmpty &&
        _birthYearController.text.trim().isNotEmpty &&
        _birthMonthController.text.trim().isNotEmpty &&
        _birthDayController.text.trim().isNotEmpty;
  }

  /// Updates the selected customer's information
  void editCustomer() {
    if (selectedCustomer != null) {
      Customer updatedCustomer = Customer(
          selectedCustomer!.id,
          _firstNameController.text,
          _lastNameController.text,
          _streetAddressController.text,
          _cityController.text,
          _provinceController.text,
          _postalCodeController.text,
          int.parse(_birthYearController.text),
          int.parse(_birthMonthController.text),
          int.parse(_birthDayController.text)
      );
      setState(() {
        customerDAO.updateCustomer(updatedCustomer);
        int index = customerList.indexWhere((customer) => customer.id == updatedCustomer.id);
        if (index != -1) {
          customerList[index] = updatedCustomer;
        }
        selectedCustomer = updatedCustomer;
        _clearForm();
      });
    }
  }

  /// Asks user to confirm and remove selected customer
  void removeCustomer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate("deleteTitle")!),
          content: Text(AppLocalizations.of(context)!.translate("deleteConfirm")!),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate("yes")!),
              onPressed: () {
                if (selectedCustomer != null) {
                  customerDAO.deleteCustomer(selectedCustomer!);
                  setState(() {
                    customerList.remove(selectedCustomer);
                    selectedCustomer = null;
                    editing = false;
                  });
                  _clearForm();
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate("no")!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Displays an AlertDialog with instructions for how to use the interface.
  void displayInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate("instructionCustomerList")!),
          content: Text(AppLocalizations.of(context)!.translate("instructionCustomerListText")!),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }




}