import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/parking/parking_bloc.dart';
import 'package:parking_user/blocs/parking/parking_event.dart';
import 'package:parking_user/blocs/parking/parking_state.dart';
import 'package:parking_user/repositories/parking_repository.dart';
import 'package:parking_user/utilities/user_session.dart';
import 'home_view.dart';
import 'my_parkings_view.dart';
import 'profile_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  // Dynamisk navigering
  static void setActivePage(BuildContext context, Widget page) {
    final state = context.findAncestorStateOfType<_MainLayoutState>();
    state?._setActivePage(page);
  }

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late Widget _activePage;
  int _activeParkingCount = 0;

  final ParkingRepository parkingRepository = ParkingRepository();

  final List<Widget> _defaultPages = [
    const HomeView(),
    const MyParkingsView(),
    const ProfileView(),
   ];

  @override
  void initState() {
    super.initState();

    // Initialisera standard-sidorna med parkingRepository
    // _defaultPages.addAll([
    //   HomeView(), // Pass parkingRepository här
    //   MyParkingsView(), // Om denna också behöver det
    //   ProfileView(),
    // ]);


    _activePage = _defaultPages[_currentIndex];
    _loadActiveParkingCount();
  }

  void _setActivePage(Widget page) {
    setState(() {
      _activePage = page;
    });
  }

  void _resetToDefaultPage() {
    setState(() {
      _activePage = _defaultPages[_currentIndex];
    });
  }


  void _loadActiveParkingCount() {
    final userEmail = UserSession().email;
    if (userEmail != null) {
      context.read<ParkingBloc>().add(LoadActiveParkings(userEmail));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARKOMAT'),
        titleTextStyle: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
        leading: _activePage != _defaultPages[_currentIndex]
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _resetToDefaultPage,
              )
            : null,
      ),
      body: _activePage,
      bottomNavigationBar: BlocBuilder<ParkingBloc, ParkingState>(
        builder: (context, state) {
          if (state is ActiveParkingsLoaded) {
            _activeParkingCount = state.activeParkings.length;
          } else if (state is ParkingError) {
            _activeParkingCount = 0; 
          }

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _activePage = _defaultPages[index];
              });
              _loadActiveParkingCount();
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_parking),
                label: 'Parkering',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.access_time),
                    if (_activeParkingCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_activeParkingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Mina Parkeringar',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Mitt Konto',
              ),
            ],
            selectedItemColor: Colors.red,
          );
        },
      ),
    );
  }
}