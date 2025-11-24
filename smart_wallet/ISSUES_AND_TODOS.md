# 🐛 Issues Found & TODO List - Smart Wallet App

## 📋 Summary
The Flutter app was created based on AGENTS.md but has several critical issues that need to be addressed before it can connect to the backend properly.

---

## ❌ CRITICAL ISSUES

### 1. **Navigation Bar Not Persistent** 🔴
**Problem:** Bottom navigation bar only exists in Dashboard screen
- Currently in: `lib/features/dashboard/screens/dashboard_screen.dart` (line 56)
- Missing in: Transactions, Analytics, Subscription screens
- **Impact:** Poor UX, users can't navigate between main sections

**Files Affected:**
- `lib/features/dashboard/screens/dashboard_screen.dart`
- `lib/features/transactions/screens/transactions_screen.dart`
- `lib/features/analytics/screens/analytics_screen.dart`
- `lib/features/subscription/screens/subscription_screen.dart`

**Solution:** Create a MainNavigationWrapper widget that wraps all main screens

---

### 2. **Login Form Position Too High** 🟡
**Problem:** Form fields appear too high on screen
- Current spacing: Only 32px from top (`login_screen.dart` line 22)
- **Impact:** Poor UX, feels cramped

**Files Affected:**
- `lib/features/auth/screens/login_screen.dart`

**Solution:** Increase vertical spacing and center form better

---

### 3. **Mock Data Not Removed** 🔴
**Problem:** App uses hardcoded sample data instead of API calls

#### a) TransactionModel.sample()
- **Location:** `lib/core/models/transaction_model.dart` (line 18)
- **Used in:** 
  - `lib/features/dashboard/widgets/recent_transactions.dart` (line 11)
  - `lib/features/transactions/screens/transactions_screen.dart` (line 15)
- **Impact:** Dashboard and Transactions show fake data

#### b) UserModel.demo()
- **Location:** `lib/core/models/user_model.dart` (line 14)
- **Used in:** `lib/core/services/auth_service.dart` (lines 30, 45)
- **Impact:** Shows demo user instead of real logged-in user

#### c) Hardcoded Balance
- **Location:** `lib/features/dashboard/widgets/balance_card.dart` (line 27)
- **Value:** "24,560.00 MXN" (hardcoded)
- **Impact:** Doesn't show real user balance

#### d) Demo Auth Tokens
- **Location:** `lib/core/services/auth_service.dart` (lines 44, 65, 89)
- **Values:** "demo_token", "demo_token_registered", "demo_token_refreshed"
- **Impact:** Authentication doesn't work with real backend

---

### 4. **Missing Dependencies** 🔴
**Problem:** pubspec.yaml doesn't include required packages from AGENTS.md

**Currently Missing:**
- ❌ `dio: ^5.3.2` (using `http` instead)
- ❌ `flutter_secure_storage: ^9.0.0` (using `shared_preferences` for tokens)
- ❌ `fl_chart: ^0.65.0` (for analytics charts)
- ✅ `intl: ^0.19.0` (already installed)

**File:** `smart_wallet/pubspec.yaml`

---

### 5. **AuthService Not Using Real API** 🔴
**Problem:** Authentication uses fake delays instead of API calls

**Code Issues:**
```dart
// lib/core/services/auth_service.dart
Future<bool> login(String email, String password) async {
  _setLoading(true);
  try {
    // This demo login simulates API behaviour for the prototype.
    await Future<void>.delayed(const Duration(milliseconds: 500)); // ❌ FAKE!
    if (email.isEmpty || password.isEmpty) {
      throw const AuthException('Credenciales invalidas');
    }
    _accessToken = 'demo_token'; // ❌ FAKE TOKEN!
    _user = UserModel.demo(email: email); // ❌ DEMO USER!
    await StorageService.saveToken(_accessToken!);
    _errorMessage = null;
    notifyListeners();
    return true;
  }
  // ...
}
```

**Should be calling:**
- POST `/api/auth/login` with `user_id` and `password`
- POST `/api/auth/register` with `user_id`, `email`, `password`
- POST `/api/auth/refresh` for token refresh

**File:** `lib/core/services/auth_service.dart`

---

### 6. **ApiService Incomplete** 🟡
**Problem:** ApiService is too basic, missing features from AGENTS.md

**Currently Has:**
- Basic GET/POST methods
- Simple response handling

**Missing:**
- Dio interceptors for automatic token injection
- Token refresh logic on 401 errors
- All endpoint methods (transactions, goals, AI chat, etc.)
- Proper error handling

**File:** `lib/core/services/api_service.dart`

---

## ✅ TODO LIST

### Priority 1: Critical Fixes (Must Fix First)
- [ ] **Install missing dependencies** (`dio`, `flutter_secure_storage`, `fl_chart`)
- [ ] **Create persistent bottom navigation wrapper** (MainNavigationScreen)
- [ ] **Remove all mock/sample data** from TransactionModel, UserModel
- [ ] **Fix AuthService** to use real API endpoints
- [ ] **Implement complete ApiService** with interceptors and token refresh

### Priority 2: UI/UX Improvements
- [ ] **Fix login screen layout** (increase spacing, center form)
- [ ] **Connect BalanceCard to real API** (remove hardcoded balance)
- [ ] **Connect RecentTransactions to real API** (remove sample data)
- [ ] **Add loading states** for all API calls
- [ ] **Add error handling** with user-friendly messages

### Priority 3: Features & Polish
- [ ] **Review terminal logs** for API connection issues
- [ ] **Fix subscription navigation** (ensure bottom nav works)
- [ ] **Add proper error feedback** throughout app
- [ ] **Test all screens** with real backend

---

## 🔍 Code References

### Files to Fix:
1. `lib/main.dart` - Add navigation wrapper
2. `lib/core/services/auth_service.dart` - Real API calls
3. `lib/core/services/api_service.dart` - Complete implementation
4. `lib/core/models/transaction_model.dart` - Remove sample()
5. `lib/core/models/user_model.dart` - Remove demo()
6. `lib/features/dashboard/widgets/balance_card.dart` - API integration
7. `lib/features/dashboard/widgets/recent_transactions.dart` - API integration
8. `lib/features/auth/screens/login_screen.dart` - Layout fix
9. `pubspec.yaml` - Add dependencies

### Terminal Logs to Check:
- API connection errors
- HTTP request failures
- Token refresh issues
- CORS errors (if any)

---

## 📊 Progress Tracking

**Overall Progress:** 15 issues identified
- 🔴 Critical: 8 issues
- 🟡 Important: 7 issues
- ✅ Completed: 0 issues

**Estimated Time:** 4-6 hours to fix all issues

---

## 🎯 Next Steps

1. Start with installing dependencies
2. Create navigation wrapper
3. Remove mock data
4. Implement real API calls
5. Test with backend
6. Fix UI issues

