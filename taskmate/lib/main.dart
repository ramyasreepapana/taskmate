import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/task_form_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskMateApp());
}

class TaskMateApp extends StatelessWidget {
  const TaskMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, primary: Colors.indigo, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<ProgressScreenState> _progressKey = GlobalKey<ProgressScreenState>();

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) _homeKey.currentState?.loadDashboardData();
    if (index == 2) _progressKey.currentState?.loadProgressData();
  }

  Future<void> _openAddTaskScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormScreen()),
    );
    if (result == true) {
      _homeKey.currentState?.loadDashboardData();
      _progressKey.currentState?.loadProgressData();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(key: _homeKey, onNavigateToTasks: () => _onTabTapped(1)),
      const TaskListScreen(),
      ProgressScreen(key: _progressKey),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskScreen,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        tooltip: 'Add Task',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        indicatorColor: Colors.indigo.shade100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.indigo), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.check_box_outlined), selectedIcon: Icon(Icons.check_box, color: Colors.indigo), label: 'My Tasks'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights, color: Colors.indigo), label: 'Progress'),
        ],
      ),
    );
  }
}
