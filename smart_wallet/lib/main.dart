import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_wallet/core/constants/app_constants.dart';
import 'package:smart_wallet/core/models/goal_model.dart';
import 'package:smart_wallet/core/models/transaction_model.dart';
import 'package:smart_wallet/core/services/auth_service.dart';
import 'package:smart_wallet/core/services/local_database_service.dart';
import 'package:smart_wallet/core/services/payment_service.dart';
import 'package:smart_wallet/core/services/theme_service.dart';
import 'package:smart_wallet/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:smart_wallet/features/analytics/screens/analytics_screen.dart';
import 'package:smart_wallet/features/analytics/screens/reports_screen.dart';
import 'package:smart_wallet/features/auth/screens/forgot_password_screen.dart';
import 'package:smart_wallet/features/auth/screens/login_screen.dart';
import 'package:smart_wallet/features/auth/screens/register_screen.dart';
import 'package:smart_wallet/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_wallet/shared/widgets/main_navigation.dart';
import 'package:smart_wallet/features/goals/screens/add_goal_screen.dart';
import 'package:smart_wallet/features/goals/screens/goal_detail_screen.dart';
import 'package:smart_wallet/features/goals/screens/goals_screen.dart';
import 'package:smart_wallet/features/market/screens/investment_analysis_screen.dart';
import 'package:smart_wallet/features/market/screens/market_screen.dart';
import 'package:smart_wallet/features/profile/screens/profile_screen.dart';
import 'package:smart_wallet/features/profile/screens/settings_screen.dart';
import 'package:smart_wallet/features/reminders/screens/add_reminder_screen.dart';
import 'package:smart_wallet/features/reminders/screens/reminders_screen.dart';
import 'package:smart_wallet/features/subscription/screens/payment_screen.dart';
import 'package:smart_wallet/features/subscription/screens/subscription_screen.dart';
import 'package:smart_wallet/features/transactions/screens/add_transaction_screen.dart';
import 'package:smart_wallet/features/transactions/screens/transaction_detail_screen.dart';
import 'package:smart_wallet/features/transactions/screens/transactions_screen.dart';
import 'package:smart_wallet/shared/theme/app_theme.dart';

void main() async {
  // Inicializar el databaseFactory para Windows/Desktop antes de cualquier otra cosa
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabaseService.initializeDatabaseFactory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider(create: (_) => PaymentService()),
      ],
      child: const SmartWalletApp(),
    ),
  );
}

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeService.themeMode,
          home: const AuthGate(),
          routes: {
            LoginScreen.routeName: (_) => const LoginScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),
            ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
            DashboardScreen.routeName: (_) => const DashboardScreen(),
            TransactionsScreen.routeName: (_) => const TransactionsScreen(),
            AddTransactionScreen.routeName: (_) => const AddTransactionScreen(),
            GoalsScreen.routeName: (_) => const GoalsScreen(),
            AddGoalScreen.routeName: (_) => const AddGoalScreen(),
            AiChatScreen.routeName: (_) => const AiChatScreen(),
            AnalyticsScreen.routeName: (_) => const AnalyticsScreen(),
            ReportsScreen.routeName: (_) => const ReportsScreen(),
            RemindersScreen.routeName: (_) => const RemindersScreen(),
            AddReminderScreen.routeName: (_) => const AddReminderScreen(),
            MarketScreen.routeName: (_) => const MarketScreen(),
            InvestmentAnalysisScreen.routeName: (_) =>
                const InvestmentAnalysisScreen(),
            SubscriptionScreen.routeName: (_) => const SubscriptionScreen(),
            PaymentScreen.routeName: (_) => const PaymentScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
            SettingsScreen.routeName: (_) => const SettingsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == TransactionDetailScreen.routeName &&
                settings.arguments is TransactionModel) {
              final transaction = settings.arguments as TransactionModel;
              return MaterialPageRoute(
                builder: (_) => TransactionDetailScreen(model: transaction),
                settings: settings,
              );
            }
            if (settings.name == GoalDetailScreen.routeName &&
                settings.arguments is GoalModel) {
              final goal = settings.arguments as GoalModel;
              return MaterialPageRoute(
                builder: (_) => GoalDetailScreen(goal: goal),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return const MainNavigation();
        }
        return const LoginScreen();
      },
    );
  }
}
