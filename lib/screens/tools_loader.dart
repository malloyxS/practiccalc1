import 'package:flutter/material.dart';

import '../widgets/deferred_loader.dart';
import 'calculator_screen.dart' deferred as calc;
import 'converter_screen.dart' deferred as conv;

class CalculatorLoader extends StatelessWidget {
  const CalculatorLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredLoader(
      load: calc.loadLibrary,
      builder: () => calc.CalculatorScreen(),
    );
  }
}

class ConverterLoader extends StatelessWidget {
  const ConverterLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return DeferredLoader(
      load: conv.loadLibrary,
      builder: () => conv.ConverterScreen(),
    );
  }
}
