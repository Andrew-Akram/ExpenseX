/// App-wide string constants.
class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'Smart Expense Tracker';
  static const String appTagline = 'Track. Analyse. Save.';

  // ── Navigation labels ─────────────────────────────────────────────────────
  static const String navDashboard  = 'Dashboard';
  static const String navExpenses   = 'Expenses';
  static const String navAnalytics  = 'Analytics';
  static const String navSettings   = 'Settings';

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const String thisMonth       = 'This Month';
  static const String today           = 'Today';
  static const String topCategory     = 'Top Category';
  static const String recentExpenses  = 'Recent Expenses';
  static const String seeAll          = 'See All';
  static const String weeklyOverview  = 'Weekly Overview';

  // ── Expense ───────────────────────────────────────────────────────────────
  static const String addExpense      = 'Add Expense';
  static const String editExpense     = 'Edit Expense';
  static const String deleteExpense   = 'Delete Expense';
  static const String expenseTitle    = 'Title';
  static const String expenseAmount   = 'Amount';
  static const String expenseCategory = 'Category';
  static const String expenseDate     = 'Date';
  static const String expenseNote     = 'Note (optional)';
  static const String noExpenses      = 'No expenses yet';
  static const String noExpensesDesc  = 'Tap + to add your first expense';
  static const String searchExpenses  = 'Search expenses…';
  static const String filterBy        = 'Filter';
  static const String sortBy          = 'Sort by';
  static const String allCategories   = 'All';

  // ── Category ──────────────────────────────────────────────────────────────
  static const String categories      = 'Categories';
  static const String addCategory     = 'Add Category';
  static const String editCategory    = 'Edit Category';
  static const String categoryName    = 'Category Name';
  static const String pickColor       = 'Pick a colour';
  static const String pickIcon        = 'Pick an icon';
  static const String noCategories    = 'No categories found';

  // ── Budget ────────────────────────────────────────────────────────────────
  static const String budget             = 'Budget';
  static const String monthlyBudget      = 'Monthly Budget';
  static const String setBudget          = 'Set Budget';
  static const String budgetAmount       = 'Budget Amount';
  static const String budgetAlert80      = 'You\'ve used 80% of your budget!';
  static const String budgetAlertOver    = 'You\'ve exceeded your budget!';
  static const String noBudget           = 'No budget set';
  static const String noBudgetDesc       = 'Set a monthly budget to track spending limits';

  // ── Analytics ─────────────────────────────────────────────────────────────
  static const String analytics      = 'Analytics';
  static const String weekly         = 'Weekly';
  static const String monthly        = 'Monthly';
  static const String yearly         = 'Yearly';
  static const String categoryBreakdown = 'Category Breakdown';
  static const String spendingTrend  = 'Spending Trend';
  static const String monthlyOverview = 'Monthly Overview';

  // ── Export ────────────────────────────────────────────────────────────────
  static const String export         = 'Export';
  static const String exportPdf      = 'Export as PDF';
  static const String exportCsv      = 'Export as CSV';
  static const String shareReport    = 'Share Report';
  static const String generating     = 'Generating…';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String setupPin       = 'Set Up PIN';
  static const String enterPin       = 'Enter PIN';
  static const String confirmPin     = 'Confirm PIN';
  static const String pinMismatch    = 'PINs do not match. Try again.';
  static const String pinIncorrect   = 'Incorrect PIN';
  static const String biometric      = 'Use Biometrics';
  static const String enableBiometric= 'Enable biometric unlock';
  static const String authFailed     = 'Authentication failed';
  static const String skip           = 'Skip';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String settings       = 'Settings';
  static const String appearance     = 'Appearance';
  static const String darkMode       = 'Dark Mode';
  static const String currency       = 'Currency';
  static const String security       = 'Security';
  static const String changePIN      = 'Change PIN';
  static const String manageBudgets  = 'Manage Budgets';
  static const String manageCategories = 'Manage Categories';
  static const String about          = 'About';

  // ── Common actions ────────────────────────────────────────────────────────
  static const String save           = 'Save';
  static const String cancel         = 'Cancel';
  static const String delete         = 'Delete';
  static const String edit           = 'Edit';
  static const String confirm        = 'Confirm';
  static const String retry          = 'Retry';
  static const String loading        = 'Loading…';
  static const String somethingWrong = 'Something went wrong';
  static const String tryAgain       = 'Please try again';
}
