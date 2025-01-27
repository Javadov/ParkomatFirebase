import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/blocs/auth/auth_bloc.dart';
import 'package:parking_admin/blocs/auth/auth_event.dart';
import 'package:parking_admin/blocs/auth/auth_state.dart';
import 'package:parking_admin/blocs/dashboard/dashboard_bloc.dart';
import 'package:parking_admin/blocs/parking/parking_bloc.dart';
// import 'package:parking_admin/blocs/parking/parking_event.dart';
import 'package:parking_admin/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_admin/firebase_options.dart';
import 'package:parking_admin/repositories/auth_repository.dart';
import 'package:parking_admin/repositories/parking_repository.dart';
import 'package:firebase_repositories/src/admin/parking_space_repository.dart';
import 'package:parking_admin/views/dashboard_view.dart';
import 'package:parking_admin/views/parking_spaces_view.dart';
import 'package:parking_admin/views/parkings_view.dart';
import 'package:parking_admin/views/login_view.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ParkingAdminApp());
}

class ParkingAdminApp extends StatelessWidget {
  const ParkingAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        RepositoryProvider<ParkingSpaceRepository>(
          create: (_) => ParkingSpaceRepository(),
        ),
        RepositoryProvider<ParkingRepository>(
          create: (_) => ParkingRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(context.read<ParkingRepository>()),
          ),
          BlocProvider<ParkingSpaceBloc>(
            create: (context) => ParkingSpaceBloc(context.read<ParkingSpaceRepository>()),
          ),
          BlocProvider<ParkingBloc>(
            create: (context) => ParkingBloc(parkingRepository: context.read<ParkingRepository>()),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          child: MaterialApp(
            title: 'Parking Admin',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
            ),
            home: const MainLayout(),
            routes: {
              '/login': (context) => const LoginView(),
            },
          ),
        ),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const DashboardView(),
    const ParkingSpacesView(),
    ParkingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (index == 3) {
                // Logout button logic
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_parking),
                label: Text('Parking Spaces'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor),
                label: Text('Parkings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                label: Text('Logout'),
              ),
            ],
          ),
          Expanded(
            child: _selectedIndex < 3 ? _views[_selectedIndex] : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}