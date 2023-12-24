// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/edit_category_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../models/budget_category.dart';
import '../models/incoming_category.dart';
import '../services/local_database.dart';
import '../utils/app_constants.dart';
import '../view_models/bottom_sheet_action.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late Future<List<List<dynamic>>> _future;
  late final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _future = getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            List<BudgetCategory> budgetCategories =
                snapshot.data[0] ?? [].cast<BudgetCategory>();
            List<IncomingCategory> incomingCategories =
                snapshot.data[1] ?? [].cast<IncomingCategory>();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'CATEGORIAS',
                  style: TextStyle(fontSize: 14),
                ),
                bottom: TabBar(
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Orçamento'),
                      Tab(text: 'Rendimentos'),
                    ]),
              ),
              floatingActionButton: FloatingActionButton(
                  backgroundColor: AppConstants.primaryColor,
                  onPressed: !_isLoading
                      ? () => addCategory(
                          context,
                          _tabController.index == 0
                              ? CategoryType.Budget
                              : CategoryType.Incoming)
                      : null,
                  child: const Icon(Icons.add)),
              body: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Tab(
                        height: double.infinity,
                        child: ListView.builder(
                            itemCount: budgetCategories.length,
                            itemBuilder: (ctx, index) {
                              var category = budgetCategories[index];

                              return CustomCard(
                                label: category.description,
                                description: 'Categoria de Orçamento',
                                icon: Icons.attach_money,
                                options: [
                                  BottomSheetAction(
                                      label: 'Editar',
                                      icon: Icons.edit,
                                      onPressed: () => editCategory(
                                            context,
                                            category,
                                            CategoryType.Budget,
                                          )),
                                  BottomSheetAction(
                                      label: 'Excluir',
                                      icon: Icons.delete,
                                      onPressed: () => deleteCategory(
                                            context,
                                            category,
                                            CategoryType.Budget,
                                          )),
                                ],
                              );
                            })),
                    Tab(
                        height: double.infinity,
                        child: ListView.builder(
                            itemCount: incomingCategories.length,
                            itemBuilder: (ctx, index) {
                              var category = incomingCategories[index];

                              return CustomCard(
                                label: category.description,
                                description: 'Categoria de Rendimento',
                                icon: Icons.account_balance_wallet,
                                options: [
                                  BottomSheetAction(
                                      label: 'Editar',
                                      icon: Icons.edit,
                                      onPressed: () => editCategory(
                                            context,
                                            category,
                                            CategoryType.Incoming,
                                          )),
                                  BottomSheetAction(
                                      label: 'Excluir',
                                      icon: Icons.delete,
                                      onPressed: () => deleteCategory(
                                            context,
                                            category,
                                            CategoryType.Incoming,
                                          )),
                                ],
                              );
                            })),
                  ]),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<List<dynamic>>> getCategories() async {
    return [
      await _localDatabase.getBudgetCategories(),
      await _localDatabase.getIncomingCategories()
    ];
  }

  addCategory(BuildContext context, CategoryType type) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (builder) {
          return EditCategoryBottomSheet(
              onConfirm: (String description, bool isActive) async {
            setState(() => _isLoading = true);

            switch (type) {
              case CategoryType.Budget:
                await _localDatabase.createBudgetCategory(
                    description: description);
                break;
              case CategoryType.Incoming:
                await _localDatabase.createIncomingCategory(
                    description: description);
                break;
            }

            _future = getCategories();

            setState(() => _isLoading = false);
          });
        });
  }

  editCategory(BuildContext context, dynamic category, CategoryType type) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        context: context,
        builder: (builder) {
          return EditCategoryBottomSheet(
              description: category.description,
              isActive: category.isActive,
              onConfirm: (String description, bool isActive) async {
                setState(() => _isLoading = true);

                switch (type) {
                  case CategoryType.Budget:
                    await _localDatabase.updateBudgetCategory(
                        id: (category as BudgetCategory).id,
                        description: description,
                        isActive: isActive);
                    break;
                  case CategoryType.Incoming:
                    await _localDatabase.updateIncomingCategory(
                        id: (category as IncomingCategory).id,
                        description: description,
                        isActive: isActive);
                    break;
                }

                _future = getCategories();

                setState(() => _isLoading = false);
              });
        });
  }

  deleteCategory(BuildContext context, dynamic category, CategoryType type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Deseja realmente excluir a categoria "${category.description}"?',
              description:
                  'Esta exclusão somente será realizada caso não haja nenhum registro ligado a este.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                switch (type) {
                  case CategoryType.Budget:
                    await _localDatabase.deleteBudgetCategory(
                        id: (category as BudgetCategory).id);
                    break;
                  case CategoryType.Incoming:
                    await _localDatabase.deleteIncomingCategory(
                        id: (category as IncomingCategory).id);
                    break;
                }

                _future = getCategories();

                setState(() => _isLoading = false);
              });
        });
  }
}

enum CategoryType {
  Budget,
  Incoming,
}
