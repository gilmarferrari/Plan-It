import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import '../components/custom_rounded_button.dart';
import '../utils/app_constants.dart';
import '../utils/local_storage.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  final int _pageCount = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackgroundColor(
          pageController: _pageController,
          pageCount: _pageCount,
          colors: const [Colors.white],
          child: Stack(children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: List<Widget>.generate(
                _pageCount,
                _getPageByIndex,
              ),
            )
          ])),
    );
  }

  Widget _getPageByIndex(int index) {
    Widget tutorialPage;
    var size = MediaQuery.of(context).size;

    switch (index) {
      case 0:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Bem vindo ao Plan It!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'Preparamos para você um tutorial simples e direto, com o intuito de explicar as principais funcionalidades do aplicativo.\n\nDeseja prosseguir?',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: const Icon(
                  Icons.auto_stories,
                  size: 120,
                ),
              ),
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Pular',
                      onTap: skipTutorial,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Vamos lá',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 1:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Privacidade dos dados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'Prezamos pela privacidade dos seus dados. Eles não vão além do seu dispositivo.\n\nOs dados inseridos no Plan It são cadastrados em um banco de dados local, estando vísiveis apenas para você.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 120,
                ),
              ),
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Próximo',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 2:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Personalize como quiser',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'No Plan It, você é quem decide.\nCrie e customize suas categorias, tipos de pagamento e até mesmo as fontes pagadoras dos seus rendimentos.\n\nNão irá mais utilizar alguma delas? Sem problemas! Você pode inativá-las, fazendo com que não apareçam no cadastro de registros futuros.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/videos/Categories.gif',
                  height: size.height - 390,
                  width: size.width - 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Anterior',
                      onTap: previousPage,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Próximo',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 3:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Rendimentos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'Cadastre seus rendimentos detalhadamente.\n\nAlém de ser possível incluí-los para as suas categorias personalizadas, você pode optar por informar os descontos do rendimento, juntamente com o valor bruto. Desta maneira, você poderá ter um controle mais minucioso dos seus rendimentos reais.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/videos/Incomings.gif',
                  height: size.height - 390,
                  width: size.width - 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Anterior',
                      onTap: previousPage,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Próximo',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 4:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Despesas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'O cadastro de despesas não é diferente: o detalhamento é nossa prioridade!\n\nAlém da categoria e tipo de pagamento — que são customizáveis —, você pode informar a data de entrada, data de pagamento, valor e descrição (campo de texto livre).',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/videos/Expenses.gif',
                  height: size.height - 390,
                  width: size.width - 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Anterior',
                      onTap: previousPage,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Próximo',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 5:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Orçamento',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'Planeje o seu ano e reduza a surpresa no final do mês.\n\nVocê pode orçar seus gastos nas categorias customizáveis, por mês. A barra de progresso informará o percentual gasto em determinda categoria e mês, tendo como limite o valor orçado.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/videos/Budget.gif',
                  height: size.height - 390,
                  width: size.width - 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Anterior',
                      onTap: previousPage,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Próximo',
                      onTap: nextPage,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      case 6:
        tutorialPage = Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
                child: const Text(
                  'Relatórios',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                'Faça uma análise completa da sua vida financeira. Visualize seus gastos por ano, mês e/ou categoria.\n\nTenha noção das despesas pendentes e agendadas. Agora fica fácil não deixar as contas atrasarem!',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Container(
                padding: const EdgeInsets.all(25),
                child: Image.asset(
                  'assets/videos/Report.gif',
                  height: size.height - 390,
                  width: size.width - 40,
                  fit: BoxFit.fitHeight,
                ),
              )
            ]),
            Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomRoundedButton(
                      label: 'Anterior',
                      onTap: previousPage,
                      stroked: true,
                      marginRight: 5,
                    ),
                    CustomRoundedButton(
                      label: 'Finalizar',
                      onTap: finishTutorial,
                      marginLeft: 5,
                    ),
                  ],
                ))
          ],
        );
        break;
      default:
        tutorialPage = Container();
        break;
    }

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: tutorialPage);
  }

  previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  nextPage() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  finishTutorial() async {
    Navigator.of(context).pop();
    await LocalStorage.saveBool(AppConstants.isTutorialCompleteKey, true);
  }

  skipTutorial() async {
    Navigator.of(context).pop();
    await LocalStorage.saveBool(AppConstants.isTutorialCompleteKey, true);
  }
}
