import 'package:flutter/material.dart';
import 'core/config/env.dart';
import 'app_widget.dart';

void main() {
  Env.currentEnv = Environment.prod;

  // Inicialize dependências de PROD aqui

  runApp(const AppWidget());
}
