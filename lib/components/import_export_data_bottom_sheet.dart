// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/local_database.dart';
import '../view_models/sql_table.dart';
import 'custom_button.dart';

class ImportExportDataBottomSheet extends StatefulWidget {
  final ActionType actionType;

  const ImportExportDataBottomSheet({required this.actionType, super.key});

  @override
  State<ImportExportDataBottomSheet> createState() =>
      _ImportExportDataBottomSheetState();
}

class _ImportExportDataBottomSheetState
    extends State<ImportExportDataBottomSheet> {
  late Future<List<SQLTable>> _future;
  final LocalDatabase _localDatabase = LocalDatabase();

  @override
  void initState() {
    super.initState();
    _future = getTables();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<SQLTable> tables = snapshot.data ?? [].cast<SQLTable>();

            return Container(
                height: (tables.length * 54) + 64,
                constraints: const BoxConstraints(maxHeight: 450),
                width: double.infinity,
                child: Column(children: [
                  Flexible(
                    child: ListView.builder(
                      itemCount: tables.length,
                      itemBuilder: ((context, index) {
                        var table = tables[index];

                        return Row(children: [
                          Checkbox(
                              value: table.isSelected,
                              onChanged: (checked) {
                                setState(() =>
                                    table.isSelected = (checked ?? false));
                              }),
                          Text(table.description)
                        ]);
                      }),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: CustomButton(
                        label: widget.actionType == ActionType.ImportData
                            ? 'Importar'
                            : 'Exportar',
                        onSubmit: () => onConfirm(context, tables),
                        height: 15),
                  ),
                ]));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<List<SQLTable>> getTables() async {
    List<SQLTable> tables = [];

    switch (widget.actionType) {
      case ActionType.ExportData:
        await _localDatabase.getTables().then((existingTables) {
          tables = existingTables;

          if (tables.isEmpty) {
            Navigator.pop(context);
          }
        });
        break;
      case ActionType.ImportData:
        await _localDatabase.getFileTables().then((existingTables) {
          tables = existingTables;

          if (tables.isEmpty) {
            Navigator.pop(context);
          }
        });
        break;
    }

    return tables;
  }

  onConfirm(BuildContext context, List<SQLTable> tables) async {
    var selectedTables = tables.where((t) => t.isSelected).toList();

    switch (widget.actionType) {
      case ActionType.ExportData:
        await exportData(selectedTables).then((result) {
          if (result == true) {
            Navigator.pop(context);
          }
        });
        break;
      case ActionType.ImportData:
        await importData(selectedTables).then((result) {
          if (result == true) {
            Navigator.pop(context);
          }
        });
        break;
    }
  }

  Future<bool> exportData(List<SQLTable> tables) async {
    if (tables.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Nenhuma tabela selecionada.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }

    await _localDatabase.exportData(tables).then((result) {
      if (result >= 0) {
        Fluttertoast.showToast(
            msg:
                '$result ${result == 1 ? 'tabela exportada' : 'tabelas exportadas'} com sucesso.');
      } else {
        Fluttertoast.showToast(
          msg: 'A exportação dos dados falhou.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });

    return true;
  }

  Future<bool> importData(List<SQLTable> tables) async {
    if (tables.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Nenhuma tabela selecionada.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }

    await _localDatabase.importData(tables).then((result) {
      if (result > 0) {
        Fluttertoast.showToast(
            msg:
                '$result ${result == 1 ? 'registro importado' : 'registros importados'} com sucesso.');
      } else {
        Fluttertoast.showToast(
          msg: 'A importação dos dados falhou.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    });

    return true;
  }
}

enum ActionType {
  ImportData,
  ExportData,
}
