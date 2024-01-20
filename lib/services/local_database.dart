import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../models/budget_category.dart';
import '../models/budget_entry.dart';
import '../models/expense.dart';
import '../models/incoming.dart';
import '../models/incoming_category.dart';
import '../models/payer.dart';
import '../models/payment_type.dart';
import '../view_models/sql_table.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabase {
  Future<Database> _startConnection() async {
    var databasePath = await getDatabasesPath();

    var context = await openDatabase('${databasePath}planit.db', version: 1,
        onCreate: (db, version) async {
      switch (version) {
        case 1:
          db.execute('PRAGMA foreign_keys = ON');
          await db.execute('''CREATE TABLE IF NOT EXISTS BudgetCategories
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL, IsActive INTEGER NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS IncomingCategories
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL, IsActive INTEGER NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Payers
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL, RegistrationNumber TEXT,
            Type TEXT, IsActive INTEGER NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS PaymentTypes
            (ID INTEGER PRIMARY KEY, Description TEXT NOT NULL, IsActive INTEGER NOT NULL);''');

          await db.execute('''CREATE TABLE IF NOT EXISTS BudgetEntries
            (ID INTEGER PRIMARY KEY, Amount REAL NOT NULL, EntryDate TEXT NOT NULL,
            BudgetCategoryID INTEGER, FOREIGN KEY(BudgetCategoryID) REFERENCES BudgetCategories(ID));''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Expenses
            (ID INTEGER PRIMARY KEY, EntryDate TEXT NOT NULL, PaymentDate TEXT, Amount REAL NOT NULL,
            Description TEXT, BudgetCategoryID INTEGER NOT NULL, PaymentTypeID INTEGER NOT NULL,
            FOREIGN KEY(BudgetCategoryID) REFERENCES BudgetCategories(ID),
            FOREIGN KEY(PaymentTypeID) REFERENCES PaymentTypes(ID));''');

          await db.execute('''CREATE TABLE IF NOT EXISTS Incomings
            (ID INTEGER PRIMARY KEY, EntryDate TEXT NOT NULL, GrossAmount REAL NOT NULL, Discounts REAL NOT NULL,
            IncomingCategoryID INTEGER NOT NULL, PayerID INTEGER,
            FOREIGN KEY(IncomingCategoryID) REFERENCES IncomingCategories(ID),
            FOREIGN KEY(PayerID) REFERENCES Payers(ID));''');

          await db.execute('''
            INSERT INTO BudgetCategories (Description, IsActive)
            VALUES
              ('Alimentação', 1),
              ('Educação', 1),
              ('Lazer', 1),
              ('Moradia', 1),
              ('Saúde', 1),
              ('Veículos', 1),
              ('Vestuário', 1),
              ('Outros', 1)
            ''');

          await db.execute('''
            INSERT INTO IncomingCategories (Description, IsActive)
            VALUES
              ('Salário', 1),
              ('Férias', 1),
              ('13° Salário', 1),
              ('Outros', 1)
            ''');

          await db.execute('''
            INSERT INTO PaymentTypes (Description, IsActive)
            VALUES
              ('Dinheiro', 1),
              ('Cartão de Crédito', 1),
              ('Cartão de Débito', 1),
              ('Transferência Bancária', 1),
              ('Pix', 1),
              ('Boleto', 1)
            ''');
          break;
      }
    });

    return context;
  }

  Future<void> _closeConnection(Database context) async {
    await context.close();
  }

  Future<List<BudgetCategory>> getBudgetCategories(
      {bool activeOnly = false, alphabeticalOrder = false}) async {
    var context = await _startConnection();

    var budgetCategories = await context.rawQuery(
        'SELECT * FROM BudgetCategories ${activeOnly ? 'WHERE IsActive = 1' : ''}');

    await _closeConnection(context);

    budgetCategories = budgetCategories
        .map((c) => {
              'id': c['ID'],
              'description': c['Description'],
              'isActive': c['IsActive'] == 1,
            })
        .toList();

    return budgetCategories.map((c) => BudgetCategory.fromJson(c)).toList();
  }

  Future<bool> createBudgetCategory({required String description}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO BudgetCategories (Description, IsActive) VALUES (?, ?)''',
          [description, true]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateBudgetCategory(
      {required int id,
      required String description,
      required bool isActive}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          '''UPDATE BudgetCategories SET Description = ?, IsActive = ?
            WHERE ID = ?''', [description, isActive, id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteBudgetCategory({required int id}) async {
    var context = await _startConnection();

    try {
      await context
          .rawDelete('DELETE FROM BudgetCategories WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<BudgetEntry>> getBudgetEntries({int? year, int? month}) async {
    var context = await _startConnection();

    var budgetEntries = await context.rawQuery(
        '''SELECT * FROM BudgetEntries WHERE ($year IS NULL OR strftime("%Y", EntryDate) = "$year")
        AND ($month IS NULL OR strftime("%m", EntryDate) = "${month.toString().padLeft(2, '0')}");''');
    var budgetCategories = await getBudgetCategories();

    await _closeConnection(context);

    budgetEntries = budgetEntries
        .map((e) => {
              'id': e['ID'],
              'amount': e['Amount'],
              'entryDate': e['EntryDate'],
              'budgetCategory': BudgetCategory.toJson(budgetCategories
                  .firstWhere((c) => c.id == e['BudgetCategoryID'])),
            })
        .toList();

    return budgetEntries.map((e) => BudgetEntry.fromJson(e)).toList();
  }

  Future<BudgetEntry?> getBudgetEntry(
      {required int year,
      required int month,
      required int budgetCategoryID}) async {
    var context = await _startConnection();

    var budgetEntries = await context.rawQuery(
        '''SELECT * FROM BudgetEntries WHERE BudgetCategoryID = $budgetCategoryID AND strftime("%Y", EntryDate) = "$year"
        AND strftime("%m", EntryDate) = "${month.toString().padLeft(2, '0')}"''');
    var budgetCategories = await getBudgetCategories();

    await _closeConnection(context);

    budgetEntries = budgetEntries
        .map((e) => {
              'id': e['ID'],
              'amount': e['Amount'],
              'entryDate': e['EntryDate'],
              'budgetCategory': BudgetCategory.toJson(budgetCategories
                  .firstWhere((c) => c.id == e['BudgetCategoryID'])),
            })
        .toList();

    return budgetEntries.isNotEmpty
        ? BudgetEntry.fromJson(budgetEntries.first)
        : null;
  }

  Future<bool> createBudgetEntry(
      {required double amount,
      required DateTime entryDate,
      required int budgetCategoryID}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO BudgetEntries (Amount, EntryDate, BudgetCategoryID)
          VALUES (?, ?, ?)''', [amount, "$entryDate", budgetCategoryID]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateBudgetEntry(
      {required int id, required double amount}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          'UPDATE BudgetEntries SET Amount = ? WHERE ID = ?', [amount, id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteBudgetEntries(
      {required int year,
      required int month,
      required int budgetCategoryID}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete(
          '''DELETE FROM BudgetEntries WHERE BudgetCategoryID = $budgetCategoryID AND strftime("%Y", EntryDate) = "$year"
            AND strftime("%m", EntryDate) = "${month.toString().padLeft(2, '0')}"''');
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<Expense>> getExpenses(
      {bool paidOnly = false,
      bool unpaidOnly = false,
      bool scheduledOnly = false,
      bool filterEntryDateYear = false,
      int? year}) async {
    var context = await _startConnection();

    var expenses = [];

    if (paidOnly) {
      expenses = await context.rawQuery(
          '''SELECT * FROM Expenses WHERE PaymentDate IS NOT NULL AND PaymentDate <= "${DateTime.now()}"
        ORDER BY EntryDate''');
    } else if (unpaidOnly) {
      expenses = await context.rawQuery(
          '''SELECT * FROM Expenses WHERE PaymentDate IS NULL ORDER BY EntryDate''');
    } else if (scheduledOnly) {
      expenses = await context.rawQuery(
          '''SELECT * FROM Expenses WHERE PaymentDate > "${DateTime.now()}"
        ORDER BY EntryDate''');
    } else if (filterEntryDateYear) {
      expenses = await context.rawQuery(
          '''SELECT * FROM Expenses WHERE ($year IS NULL OR strftime("%Y", EntryDate) = "$year")
        ORDER BY EntryDate''');
    } else {
      expenses = await context
          .rawQuery('''SELECT * FROM Expenses WHERE ($year IS NULL OR
          (PaymentDate IS NOT NULL AND strftime("%Y", PaymentDate) = "$year") OR
          (PaymentDate IS NULL AND strftime("%Y", EntryDate) = "$year"))
        ORDER BY EntryDate''');
    }

    await _closeConnection(context);

    var budgetCategories = await getBudgetCategories();
    var paymentTypes = await getPaymentTypes();

    expenses = expenses
        .map((e) => {
              'id': e['ID'],
              'entryDate': e['EntryDate'],
              'paymentDate': e['PaymentDate'],
              'description': e['Description'],
              'amount': e['Amount'],
              'budgetCategory': BudgetCategory.toJson(budgetCategories
                  .firstWhere((c) => c.id == e['BudgetCategoryID'])),
              'paymentType': PaymentType.toJson(
                  paymentTypes.firstWhere((t) => t.id == e['PaymentTypeID']))
            })
        .toList();

    return expenses.map((e) => Expense.fromJson(e)).toList();
  }

  Future<bool> createExpense(
      {required double amount,
      required DateTime entryDate,
      DateTime? paymentDate,
      String? description,
      required int budgetCategoryID,
      required int paymentTypeID}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO Expenses (Amount, EntryDate, PaymentDate, Description, BudgetCategoryID, PaymentTypeID)
          VALUES (?, ?, ?, ?, ?, ?)''',
          [
            amount,
            "$entryDate",
            paymentDate != null ? "$paymentDate" : null,
            description,
            budgetCategoryID,
            paymentTypeID
          ]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateExpense(
      {required int id,
      required double amount,
      required DateTime entryDate,
      DateTime? paymentDate,
      String? description,
      required int budgetCategoryID,
      required int paymentTypeID}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          '''UPDATE Expenses SET Amount = ?, EntryDate = ?, PaymentDate = ?, Description = ?,
            BudgetCategoryID = ?, PaymentTypeID = ?
            WHERE ID = ?''',
          [
            amount,
            "$entryDate",
            paymentDate != null ? "$paymentDate" : null,
            description,
            budgetCategoryID,
            paymentTypeID,
            id
          ]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteExpense({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Expenses WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<IncomingCategory>> getIncomingCategories(
      {bool activeOnly = false}) async {
    var context = await _startConnection();

    var incomingCategories = await context.rawQuery(
        'SELECT * FROM IncomingCategories ${activeOnly ? 'WHERE IsActive = 1' : ''}');

    await _closeConnection(context);

    incomingCategories = incomingCategories
        .map((c) => {
              'id': c['ID'],
              'description': c['Description'],
              'isActive': c['IsActive'] == 1,
            })
        .toList();

    return incomingCategories.map((c) => IncomingCategory.fromJson(c)).toList();
  }

  Future<bool> createIncomingCategory({required String description}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO IncomingCategories (Description, IsActive) VALUES (?, ?)''',
          [description, true]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateIncomingCategory(
      {required int id,
      required String description,
      required bool isActive}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          '''UPDATE IncomingCategories SET Description = ?, IsActive = ?
            WHERE ID = ?''', [description, isActive, id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteIncomingCategory({required int id}) async {
    var context = await _startConnection();

    try {
      await context
          .rawDelete('DELETE FROM IncomingCategories WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<Incoming>> getIncomings(
      {bool paidOnly = false, int? year}) async {
    var context = await _startConnection();

    var incomings = [];

    if (paidOnly) {
      incomings = await context.rawQuery(
          '''SELECT * FROM Incomings ${paidOnly ? 'WHERE EntryDate <= "${DateTime.now()}"' : ''}
        ORDER BY EntryDate''');
    } else {
      incomings = await context.rawQuery(
          '''SELECT * FROM Incomings WHERE ($year IS NULL OR strftime("%Y", EntryDate) = "$year")
        ORDER BY EntryDate''');
    }

    await _closeConnection(context);

    var incomingCategories = await getIncomingCategories();
    var payers = await getPayers();

    incomings = incomings
        .map((i) => {
              'id': i['ID'],
              'entryDate': i['EntryDate'],
              'grossAmount': i['GrossAmount'],
              'discounts': i['Discounts'],
              'incomingCategory': IncomingCategory.toJson(incomingCategories
                  .firstWhere((c) => c.id == i['IncomingCategoryID'])),
              'payer': i['PayerID'] != null
                  ? Payer.toJson(payers.firstWhere((p) => p.id == i['PayerID']))
                  : null
            })
        .toList();

    return incomings.map((i) => Incoming.fromJson(i)).toList();
  }

  Future<bool> createIncoming(
      {required double grossAmount,
      required double discounts,
      required DateTime entryDate,
      required int incomingCategoryID,
      int? payerID}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO Incomings (GrossAmount, Discounts, EntryDate, IncomingCategoryID, PayerID)
          VALUES (?, ?, ?, ?, ?)''',
          [grossAmount, discounts, "$entryDate", incomingCategoryID, payerID]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updateIncoming(
      {required int id,
      required double grossAmount,
      required double discounts,
      required DateTime entryDate,
      required int incomingCategoryID,
      int? payerID}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          '''UPDATE Incomings SET GrossAmount = ?, Discounts = ?, EntryDate = ?, IncomingCategoryID = ?, PayerID = ? WHERE ID = ?''',
          [
            grossAmount,
            discounts,
            "$entryDate",
            incomingCategoryID,
            payerID,
            id
          ]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deleteIncoming({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Incomings WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<Payer>> getPayers({bool activeOnly = false}) async {
    var context = await _startConnection();

    var payers = await context.rawQuery(
        'SELECT * FROM Payers ${activeOnly ? 'WHERE IsActive = 1' : ''}');

    await _closeConnection(context);

    payers = payers
        .map((p) => {
              'id': p['ID'],
              'description': p['Description'],
              'registrationNumber': p['RegistrationNumber'],
              'type': p['Type'],
              'isActive': p['IsActive'] == 1,
            })
        .toList();

    return payers.map((p) => Payer.fromJson(p)).toList();
  }

  Future<bool> createPayer(
      {required String description,
      String? registrationNumber,
      String? type}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO Payers (Description, RegistrationNumber, Type, IsActive)
          VALUES (?, ?, ?, ?)''',
          [description, registrationNumber, type, true]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updatePayer(
      {required int id,
      required String description,
      required bool isActive,
      String? registrationNumber,
      String? type}) async {
    var context = await _startConnection();

    try {
      await context.rawUpdate(
          '''UPDATE Payers SET Description = ?, RegistrationNumber = ?, Type = ?, IsActive = ?
            WHERE ID = ?''',
          [description, registrationNumber, type, isActive, id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deletePayer({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM Payers WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<PaymentType>> getPaymentTypes({bool activeOnly = false}) async {
    var context = await _startConnection();

    var paymentTypes = await context.rawQuery(
        'SELECT * FROM PaymentTypes ${activeOnly ? 'WHERE IsActive = 1' : ''}');

    await _closeConnection(context);

    paymentTypes = paymentTypes
        .map((t) => {
              'id': t['ID'],
              'description': t['Description'],
              'isActive': t['IsActive'] == 1,
            })
        .toList();

    return paymentTypes.map((t) => PaymentType.fromJson(t)).toList();
  }

  Future<bool> createPaymentType({required String description}) async {
    var context = await _startConnection();

    try {
      await context.rawInsert(
          '''INSERT INTO PaymentTypes (Description, IsActive) VALUES (?, ?)''',
          [description, true]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> updatePaymentType(
      {required int id,
      required String description,
      required bool isActive}) async {
    var context = await _startConnection();

    try {
      await context
          .rawUpdate('''UPDATE PaymentTypes SET Description = ?, IsActive = ?
            WHERE ID = ?''', [description, isActive, id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<bool> deletePaymentType({required int id}) async {
    var context = await _startConnection();

    try {
      await context.rawDelete('DELETE FROM PaymentTypes WHERE ID = ?', [id]);
    } catch (_) {
      return false;
    }

    await _closeConnection(context);

    return true;
  }

  Future<List<SQLTable>> getTables() async {
    var context = await _startConnection();

    List<Map<String, dynamic>> tables = await context.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '%metadata'");

    _closeConnection(context);

    List<SQLTable> tableNames =
        tables.map((t) => SQLTable(name: t['name'])).toList();

    return tableNames;
  }

  Future<List<SQLTable>> getFileTables() async {
    var directory = await getTemporaryDirectory();
    await directory.delete(recursive: true);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    List<SQLTable> tableNames = [];

    if (result != null && result.files.single.path != null) {
      try {
        var json = await File(result.files.single.path!).readAsString();
        Map<String, dynamic> data = jsonDecode(json);

        tableNames = data.entries
            .map((e) => SQLTable(
                name: e.key,
                data: List<Map<String, dynamic>>.from(e.value ?? [])))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return tableNames;
  }

  Future<int> exportData(List<SQLTable> tables) async {
    var context = await _startConnection();
    Map<String, List<Map<String, dynamic>>> data = {};

    for (var table in tables) {
      try {
        var tableRecords =
            await context.rawQuery('SELECT * FROM ${table.name}');
        data.addAll({table.name: tableRecords});
      } catch (_) {
        continue;
      }
    }

    await _closeConnection(context);

    try {
      var directory = await getTemporaryDirectory();
      await directory.delete(recursive: true);

      var directoryPath = await FilePicker.platform.getDirectoryPath();

      if (directoryPath == null) {
        return -1;
      }

      String path = '$directoryPath/plan_it_data.json';

      File file = File(path);
      await file.writeAsString(jsonEncode(data));

      return data.length;
    } catch (_) {
      return -1;
    }
  }

  Future<int> importData(List<SQLTable> tables) async {
    var context = await _startConnection();
    int importedRecords = 0;

    for (var table in tables) {
      try {
        if (table.data != null && table.data!.isNotEmpty) {
          await context.transaction((txn) async {
            for (var record in table.data!) {
              for (var column in record.keys) {
                var id = record['ID'];

                if (column != 'ID') {
                  var updatedRows = await txn.rawUpdate(
                    'UPDATE ${table.name} SET $column = ? WHERE ID = ?',
                    [record[column], id],
                  );

                  if (updatedRows == 0) {
                    await txn.insert(table.name, record);
                  }

                  importedRecords++;
                }
              }
            }
          });
        }
      } catch (_) {
        continue;
      }
    }

    await _closeConnection(context);

    return importedRecords;
  }
}
