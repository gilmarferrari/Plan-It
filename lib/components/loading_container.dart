import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class LoadingContainer extends StatelessWidget {
  final bool showAppBar;
  const LoadingContainer({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar() : null,
      body: SizedBox(
        width: double.infinity,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Carregando',
                        ),
                        AnimatedTextKit(
                          repeatForever: true,
                          isRepeatingAnimation: true,
                          pause: const Duration(milliseconds: 500),
                          animatedTexts: [
                            TyperAnimatedText('...',
                                speed: const Duration(milliseconds: 300)),
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              ))
        ]),
      ),
    );
  }
}
