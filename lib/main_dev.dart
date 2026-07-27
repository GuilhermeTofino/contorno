import 'package:contorno/core/inject/inject.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // 1. Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://qdywxebgismxenkqvpvr.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkeXd4ZWJnaXNteGVua3F2cHZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUxMDM2MTMsImV4cCI6MjEwMDY3OTYxM30.3uS6d26P8Ih9TwV8hWsNRrwCORS2kHqe2SjEbLzsz58',
  );

  // 2. Inicializa o GetIt (Registra as dependências)
  initInject();

  // 3. Roda o App
  runApp(const AppWidget());
}
