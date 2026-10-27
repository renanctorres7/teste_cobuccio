import 'package:flutter/material.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.label = 'Carregando',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: const Center(
        child: ExcludeSemantics(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
