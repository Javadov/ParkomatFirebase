import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_user/blocs/auth/auth_bloc.dart';
import 'package:parking_user/blocs/auth/auth_event.dart';
import 'package:parking_user/blocs/auth/auth_state.dart';
import 'package:parking_user/utilities/user_session.dart';

import '../mocks/mock_http_client.dart';
import '../mocks/mock_shared_preferences.dart';

void main() {
  late AuthBloc authBloc;
  late MockHttpClient mockHttpClient;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockSharedPreferences = MockSharedPreferences();
    authBloc = AuthBloc();

    // Mock SharedPreferences globally
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    group('CheckLoginStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is logged in',
        build: () {
          UserSession().email = 'test@example.com';
          when(() => mockSharedPreferences.getBool('isLoggedIn')).thenReturn(true);
          when(() => mockSharedPreferences.setBool('isLoggedIn', true))
              .thenAnswer((_) async => true);
          when(() => mockSharedPreferences.setString('userEmail', any()))
              .thenAnswer((_) async => true);

          return authBloc;
        },
        act: (bloc) => bloc.add(CheckLoginStatus()),
        expect: () => [AuthLoading(), AuthAuthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is not logged in',
        build: () {
          UserSession().email = null;
          when(() => mockSharedPreferences.getBool('isLoggedIn'))
              .thenReturn(false);
          return authBloc;
        },
        act: (bloc) => bloc.add(CheckLoginStatus()),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
      );
    });

  group('LoginEvent', () {
    const email = 'test@example.com';
    const password = 'password';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login is successful',
      build: () {
        // Stub the mockHttpClient to return a successful response
        when(() => mockHttpClient.post(
              Uri.parse('http://localhost:8080/users/login'),
              headers: {'Content-Type': 'application/json'},
              body: '{"email":"$email","password":"$password"}',
            )).thenAnswer(
          (_) async => http.Response('{"email": "$email"}', 200),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginEvent(email, password)),
      expect: () => [AuthLoading(), AuthSuccess()],
      verify: (_) {
        verify(() => mockHttpClient.post(
              Uri.parse('http://localhost:8080/users/login'),
              headers: {'Content-Type': 'application/json'},
              body: '{"email":"$email","password":"$password"}',
            )).called(1);
      },
    );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails with invalid credentials',
        build: () {
          when(() => mockHttpClient.post(
                Uri.parse('http://localhost:8080/users/login'),
                headers: {'Content-Type': 'application/json'},
                body: '{"email":"$email","password":"$password"}',
              )).thenAnswer((_) async => http.Response('Unauthorized', 401));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginEvent(email, password)),
        expect: () => [AuthLoading(), AuthFailure('Ogiltig e-postadress eller lösenord')],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network error occurs during login',
        build: () {
          when(() => mockHttpClient.post(
                Uri.parse('http://localhost:8080/users/login'),
                headers: {'Content-Type': 'application/json'},
                body: '{"email":"$email","password":"$password"}',
              )).thenThrow(Exception('Network Error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LoginEvent(email, password)),
        expect: () => [AuthLoading(), AuthError('Nätverksfel, försök igen senare')],
      );
    });

    group('LogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
        build: () {
          when(() => mockSharedPreferences.remove('isLoggedIn'))
              .thenAnswer((_) async => true);
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutEvent()),
        expect: () => [AuthLoading(), AuthUnauthenticated()],
        verify: (_) {
          verify(() => mockSharedPreferences.remove('isLoggedIn')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when logout fails',
        build: () {
          when(() => mockSharedPreferences.remove('isLoggedIn'))
              .thenThrow(Exception('Storage Error'));
          return authBloc;
        },
        act: (bloc) => bloc.add(LogoutEvent()),
        expect: () => [AuthLoading(), AuthError('Failed to logout: Exception: Storage Error')],
      );
    });
  });
}