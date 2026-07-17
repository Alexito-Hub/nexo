import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/core/error_handler.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/data/session.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

// Simple Mocks for test isolation

class MockConnectivity implements Connectivity {
  MockConnectivity({required this.result});
  final List<ConnectivityResult> result;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => result;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value(result);
}

class MockHttpClient extends http.BaseClient {
  MockHttpClient(this.handler);
  final Future<http.Response> Function(http.BaseRequest) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      request: request,
      headers: response.headers,
    );
  }
}

class MockSessionService extends Fake implements SessionService {
  bool loggedOut = false;

  @override
  Future<void> logout() async {
    loggedOut = true;
  }
}

void main() {
  group('Unified Models Tests', () {
    test('Student merges correctly, prioritizing primary fields', () {
      const student1 = Student(
        id: '123',
        fullName: 'John Doe',
        career: 'Systems Engineering',
        faculty: 'Engineering',
        campus: 'Huancayo',
        level: 'VI',
        studyPlan: '2020',
        modality: 'Presencial',
        isEnrolled: true,
        creditsApproved: 100,
      );

      const student2 = Student(
        id: '',
        fullName: 'John D.',
        career: '',
        faculty: '',
        campus: '',
        level: '',
        studyPlan: '',
        modality: '',
        isEnrolled: false,
        lastEnrollment: '2026-1',
        creditsApproved: null,
        creditsTotal: 200,
      );

      final merged = student1.mergeWith(student2);

      expect(merged.id, '123');
      expect(merged.fullName, 'John Doe');
      expect(merged.lastEnrollment, '2026-1');
      expect(merged.creditsApproved, 100);
      expect(merged.creditsTotal, 200);
    });
  });

  group('ErrorHandler Tests', () {
    test('withFallback executes remote action if online', () async {
      final conn = ConnectivityService(
        connectivity: MockConnectivity(result: [ConnectivityResult.wifi]),
        httpClient: MockHttpClient((req) async => http.Response('', 200)),
      );
      await conn.checkNow();

      final handler = ErrorHandler(
        connectivity: conn,
        session: MockSessionService(),
      );

      var remoteCalled = false;
      var cacheCalled = false;

      final res = await handler.withFallback<String>(
        remote: () async {
          remoteCalled = true;
          return 'success';
        },
        cached: () async {
          cacheCalled = true;
          return 'cached';
        },
        operationName: 'test_op',
      );

      expect(res, 'success');
      expect(remoteCalled, true);
      expect(cacheCalled, false);
    });

    test('withFallback falls back to cache on network failure', () async {
      final conn = ConnectivityService(
        connectivity: MockConnectivity(result: [ConnectivityResult.none]),
        httpClient: MockHttpClient((req) async => http.Response('', 500)),
      );
      await conn.checkNow();

      final handler = ErrorHandler(
        connectivity: conn,
        session: MockSessionService(),
      );

      var remoteCalled = false;
      var cacheCalled = false;

      final res = await handler.withFallback<String>(
        remote: () async {
          remoteCalled = true;
          throw const NetworkException('Server down');
        },
        cached: () async {
          cacheCalled = true;
          return 'cached_data';
        },
        operationName: 'test_op',
      );

      expect(res, 'cached_data');
      expect(remoteCalled, false); // No internet check skip calling remote
      expect(cacheCalled, true);
    });

    test(
      'session expired serves cache and does NOT log out (logout is ApiClient\'s job)',
      () async {
        final conn = ConnectivityService(
          connectivity: MockConnectivity(result: [ConnectivityResult.wifi]),
          httpClient: MockHttpClient((req) async => http.Response('', 200)),
        );
        await conn.checkNow();

        final session = MockSessionService();
        final handler = ErrorHandler(connectivity: conn, session: session);

        // Con caché disponible: se sirve el caché, sin lanzar.
        final res = await handler.withFallback<String>(
          remote: () async => throw const SessionExpiredException(),
          cached: () async => 'cached',
          operationName: 'test_op',
        );

        expect(res, 'cached');
        // El logout lo dispara ApiClient.onUnauthorized (fuente única). El
        // ErrorHandler NUNCA debe cerrar sesión: eso causaba el doble-logout.
        expect(session.loggedOut, false);
      },
    );

    test('session expired rethrows when there is no cache', () async {
      final conn = ConnectivityService(
        connectivity: MockConnectivity(result: [ConnectivityResult.wifi]),
        httpClient: MockHttpClient((req) async => http.Response('', 200)),
      );
      await conn.checkNow();
      final session = MockSessionService();
      final handler = ErrorHandler(connectivity: conn, session: session);

      await expectLater(
        handler.withFallback<String>(
          remote: () async => throw const SessionExpiredException(),
          cached: () async => null,
          operationName: 'test_op',
        ),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(session.loggedOut, false);
    });

    test(
      'AuthUnavailable is transient: serves cache and keeps the session',
      () async {
        final conn = ConnectivityService(
          connectivity: MockConnectivity(result: [ConnectivityResult.wifi]),
          httpClient: MockHttpClient((req) async => http.Response('', 200)),
        );
        await conn.checkNow();
        final session = MockSessionService();
        final handler = ErrorHandler(connectivity: conn, session: session);

        final res = await handler.withFallback<String>(
          remote: () async => throw const AuthUnavailableException(),
          cached: () async => 'cached',
          operationName: 'test_op',
        );

        expect(res, 'cached');
        expect(session.loggedOut, false);
      },
    );

    test('retries once on a transient failure, then succeeds', () async {
      final conn = ConnectivityService(
        connectivity: MockConnectivity(result: [ConnectivityResult.wifi]),
        httpClient: MockHttpClient((req) async => http.Response('', 200)),
      );
      await conn.checkNow();
      final handler = ErrorHandler(
        connectivity: conn,
        session: MockSessionService(),
      );

      var attempts = 0;
      final res = await handler.withFallback<String>(
        remote: () async {
          attempts++;
          // Primer hit falla (servidor "frío" tras inactividad); el reintento
          // recupera. Este es justo el caso que rompía antes.
          if (attempts == 1) throw const NetworkException('cold start');
          return 'success';
        },
        cached: () async => null,
        operationName: 'test_op',
      );

      expect(res, 'success');
      expect(attempts, 2);
    });
  });
}
