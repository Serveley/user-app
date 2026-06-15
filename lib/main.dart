import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/service_bloc.dart';
import 'blocs/vendor_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/vendors_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const ServeleyApp());
}

class ServeleyApp extends StatelessWidget {
  const ServeleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ServiceBloc()..add(LoadServices())),
        BlocProvider(create: (context) => VendorBloc()),
      ],
      child: MaterialApp(
        title: 'Serveley',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ServicesScreen(),
    const VendorsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.design_services), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.store), label: 'Vendors'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
