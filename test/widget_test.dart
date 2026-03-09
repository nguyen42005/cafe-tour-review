import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/views/auth/login_view.dart';
import 'package:provider/provider.dart';
import 'package:mobile/view_models/auth_view_model.dart';

void main() {
  testWidgets('Login view smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
        child: const MaterialApp(home: LoginView()),
      ),
    );

    expect(find.text('Chào mừng trở lại'), findsWidgets);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
