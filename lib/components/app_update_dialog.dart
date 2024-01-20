import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import '../services/app_versions_service.dart';
import '../utils/extensions.dart';
import 'custom_button.dart';
import 'custom_text_button.dart';

class AppUpdateDialog extends StatefulWidget {
  final String downloadUrl;
  final String fileName;
  final int size;

  const AppUpdateDialog({
    required this.downloadUrl,
    required this.fileName,
    required this.size,
    super.key,
  });

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  final AppVersionsService _appVersionsService = AppVersionsService();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: _isDownloading
          ? const Center(child: CircularProgressIndicator())
          : const Icon(
              Icons.update,
              size: 40,
            ),
      title: _isDownloading
          ? Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Baixando atualização'),
                AnimatedTextKit(
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  pause: const Duration(milliseconds: 500),
                  animatedTexts: [
                    TyperAnimatedText('...',
                        speed: const Duration(milliseconds: 300)),
                  ],
                ),
              ]),
            )
          : const Text(
              'Atualização Disponível',
              textAlign: TextAlign.center,
            ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      content: Text(
          'Tamanho: ${Extensions.formatStorage(widget.size)}\n\nUma nova versão do aplicativo está disponível.\nDeseja atualizar para a versão mais recente?'),
      contentTextStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
      insetPadding: const EdgeInsets.all(30),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      actions: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
            child: CustomTextButton(
              label: 'Agora não',
              height: 15,
              onSubmit: !_isDownloading ? dismiss : null,
            ),
          ),
          Expanded(
            child: CustomButton(
              label: 'Atualizar',
              height: 15,
              onSubmit: !_isDownloading ? installLatestVersion : null,
            ),
          )
        ])
      ],
    );
  }

  void installLatestVersion() async {
    setState(() => _isDownloading = true);

    await _appVersionsService.downloadAppVersion(
        widget.downloadUrl, widget.fileName);

    setState(() => _isDownloading = false);
  }

  void dismiss() {
    Navigator.of(context).pop();
  }
}
