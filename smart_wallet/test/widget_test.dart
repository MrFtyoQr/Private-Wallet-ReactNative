import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/services/payment_service.dart';
import 'package:smart_wallet/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Muestra la pantalla de inicio de sesion por defecto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
          Provider<PaymentService>(create: (_) => PaymentService()),
        ],
        child: const SmartWalletApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ingresar'), findsOneWidget);
  });
}

