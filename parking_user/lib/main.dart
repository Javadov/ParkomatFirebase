import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/parking/parking_bloc.dart';
import 'package:parking_user/repositories/parking_repository.dart';
import 'package:parking_user/utilities/auth_check.dart';
import 'package:parking_user/utilities/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies here
  final parkingRepository = ParkingRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: MyApp(
        parkingRepository: parkingRepository,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ParkingRepository parkingRepository;

  const MyApp({
    Key? key,
    required this.parkingRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(),
        ),
        BlocProvider(
          create: (_) => ParkingBloc(parkingRepository: parkingRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Parkomat',
        themeMode: themeNotifier.themeMode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const AuthCheck(),
      ),
    );
  }
}