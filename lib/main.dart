import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'flutter_flow/revenue_cat_util.dart' as revenue_cat;

import '/backend/firebase_dynamic_links/firebase_dynamic_links.dart';
import '/offline/offline_connectivity_service.dart';
import '/offline/offline_indicator_banner.dart';
import '/offline/offline_sync_service.dart';
import '/offline/cache_warmer_service.dart';
import '/offline/offline_status_widget.dart';
import '/onboarding/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  // Initialise offline connectivity tracking as early as possible so
  // the banner reflects the correct state from the very first frame.
  OfflineConnectivityService().initialize();

  // Offline sync service temporarily disabled to fix null check crash.
  // OfflineSyncService().initialize();

  await FlutterFlowTheme.initialize();

  await FFLocalizations.initialize();

  // Initialise the onboarding service so it can read/write the
  // "has the user seen the tour?" flag from SharedPreferences. Must
  // run after FFLocalizations.initialize() because that also inits
  // the SharedPreferences instance.
  await OnboardingService.instance.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  await revenue_cat.initialize(
    "appl_DiZrRubhavetCoHsHXPmUTMAIlk",
    "goog_OmJOGuYAMEmwKIREpYjyJkXpKVP",
    loadDataAfterLaunch: true,
  );

  if (!kIsWeb) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  // Make build errors visible in release web builds. Without this, any widget
  // that throws during build is silently replaced with a grey box (the default
  // release-mode ErrorWidget), which makes "grey screen" issues nearly
  // impossible to diagnose in production. Showing the error text in a red box
  // matches Flutter's debug behaviour and surfaces the failure immediately.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.reportError(details);
    return Material(
      color: const Color(0xFFFEE2E2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontSize: 12.0,
            fontFamily: 'monospace',
            height: 1.4,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'A widget failed to build.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(details.exceptionAsString()),
                  if (details.stack != null) ...[
                    const SizedBox(height: 8.0),
                    Text(details.stack.toString().split('\n').take(15).join('\n')),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = FFLocalizations.getStoredLocale();

  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.path;
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((user) {
    revenue_cat.login(user?.uid);
  });

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = mediTrackerFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        // Auto-warm and sync tracking temporarily disabled to fix
        // null check crash. Will re-enable after root cause is found.
        // if (user?.loggedIn == true) {
        //   _onUserSignedIn();
        // }
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  /// Called whenever a user signs in. Sets up sync-status tracking
  /// and triggers an automatic cache warm (non-blocking — runs in
  /// the background so the user can start using the app immediately).
  void _onUserSignedIn() {
    try {
      // Watch the user's collections for pending writes.
      // This populates the OfflineStatusChip with real sync data.
      final userDoc = currentUserDocument;
      if (userDoc != null) {
        final ownerRef = valueOrDefault(userDoc.role, '') == 'Owner'
            ? currentUserReference
            : userDoc.ownerRef;
        if (ownerRef != null) {
          OfflineSyncService().watchCollection(
            FirebaseFirestore.instance
                .collection('User')
                .doc(ownerRef.id)
                .collection('Pharmacy'),
          );
        }
      }
      // Auto-warm the cache in the background (non-blocking).
      // We delay slightly so the app's first frame isn't delayed.
      Future.delayed(const Duration(seconds: 2), () {
        CacheWarmerService().warmCache();
      });
    } catch (e) {
      debugPrint('[main] Auto-warm setup failed: $e');
    }
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
    FFLocalizations.storeLocale(language);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Duniya',
      scrollBehavior: MyAppScrollBehavior(),
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('af'),
        Locale('hi'),
        Locale('es'),
        Locale('it'),
        Locale('sw'),
        Locale('fr'),
        Locale('nd'),
        Locale('ar'),
        Locale('pt'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Satoshi',
        // Force Satoshi on EVERY Material text style slot so any widget
        // that doesn't go through FlutterFlowTheme.of(context) — default
        // Text(), AppBar title, Button labels, SnackBar, Dialog, etc. —
        // also renders in Satoshi.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Satoshi'),
          displayMedium: TextStyle(fontFamily: 'Satoshi'),
          displaySmall: TextStyle(fontFamily: 'Satoshi'),
          headlineLarge: TextStyle(fontFamily: 'Satoshi'),
          headlineMedium: TextStyle(fontFamily: 'Satoshi'),
          headlineSmall: TextStyle(fontFamily: 'Satoshi'),
          titleLarge: TextStyle(fontFamily: 'Satoshi'),
          titleMedium: TextStyle(fontFamily: 'Satoshi'),
          titleSmall: TextStyle(fontFamily: 'Satoshi'),
          bodyLarge: TextStyle(fontFamily: 'Satoshi'),
          bodyMedium: TextStyle(fontFamily: 'Satoshi'),
          bodySmall: TextStyle(fontFamily: 'Satoshi'),
          labelLarge: TextStyle(fontFamily: 'Satoshi'),
          labelMedium: TextStyle(fontFamily: 'Satoshi'),
          labelSmall: TextStyle(fontFamily: 'Satoshi'),
        ),
        primaryTextTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Satoshi'),
          displayMedium: TextStyle(fontFamily: 'Satoshi'),
          displaySmall: TextStyle(fontFamily: 'Satoshi'),
          headlineLarge: TextStyle(fontFamily: 'Satoshi'),
          headlineMedium: TextStyle(fontFamily: 'Satoshi'),
          headlineSmall: TextStyle(fontFamily: 'Satoshi'),
          titleLarge: TextStyle(fontFamily: 'Satoshi'),
          titleMedium: TextStyle(fontFamily: 'Satoshi'),
          titleSmall: TextStyle(fontFamily: 'Satoshi'),
          bodyLarge: TextStyle(fontFamily: 'Satoshi'),
          bodyMedium: TextStyle(fontFamily: 'Satoshi'),
          bodySmall: TextStyle(fontFamily: 'Satoshi'),
          labelLarge: TextStyle(fontFamily: 'Satoshi'),
          labelMedium: TextStyle(fontFamily: 'Satoshi'),
          labelSmall: TextStyle(fontFamily: 'Satoshi'),
        ),
        primaryColor: const Color(0xFF9900FF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF9900FF),
          secondary: Color(0xFF7C3AED),
          surface: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF111827),
        ),
        cardTheme: const CardThemeData(
          elevation: 2.0,
          color: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shadowColor: Color(0x0A000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(true),
          interactive: false,
          thickness: WidgetStateProperty.all(0.0),
        ),
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Satoshi',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Satoshi'),
          displayMedium: TextStyle(fontFamily: 'Satoshi'),
          displaySmall: TextStyle(fontFamily: 'Satoshi'),
          headlineLarge: TextStyle(fontFamily: 'Satoshi'),
          headlineMedium: TextStyle(fontFamily: 'Satoshi'),
          headlineSmall: TextStyle(fontFamily: 'Satoshi'),
          titleLarge: TextStyle(fontFamily: 'Satoshi'),
          titleMedium: TextStyle(fontFamily: 'Satoshi'),
          titleSmall: TextStyle(fontFamily: 'Satoshi'),
          bodyLarge: TextStyle(fontFamily: 'Satoshi'),
          bodyMedium: TextStyle(fontFamily: 'Satoshi'),
          bodySmall: TextStyle(fontFamily: 'Satoshi'),
          labelLarge: TextStyle(fontFamily: 'Satoshi'),
          labelMedium: TextStyle(fontFamily: 'Satoshi'),
          labelSmall: TextStyle(fontFamily: 'Satoshi'),
        ),
        primaryTextTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Satoshi'),
          displayMedium: TextStyle(fontFamily: 'Satoshi'),
          displaySmall: TextStyle(fontFamily: 'Satoshi'),
          headlineLarge: TextStyle(fontFamily: 'Satoshi'),
          headlineMedium: TextStyle(fontFamily: 'Satoshi'),
          headlineSmall: TextStyle(fontFamily: 'Satoshi'),
          titleLarge: TextStyle(fontFamily: 'Satoshi'),
          titleMedium: TextStyle(fontFamily: 'Satoshi'),
          titleSmall: TextStyle(fontFamily: 'Satoshi'),
          bodyLarge: TextStyle(fontFamily: 'Satoshi'),
          bodyMedium: TextStyle(fontFamily: 'Satoshi'),
          bodySmall: TextStyle(fontFamily: 'Satoshi'),
          labelLarge: TextStyle(fontFamily: 'Satoshi'),
          labelMedium: TextStyle(fontFamily: 'Satoshi'),
          labelSmall: TextStyle(fontFamily: 'Satoshi'),
        ),
        primaryColor: const Color(0xFF9900FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9900FF),
          secondary: Color(0xFFA78BFA),
          surface: Color(0xFF111827),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFF000000),
          onSurface: Color(0xFFF9FAFB),
        ),
        cardTheme: const CardThemeData(
          elevation: 2.0,
          color: Color(0xFF1F2937),
          surfaceTintColor: Colors.transparent,
          shadowColor: Color(0x0F000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(true),
          interactive: false,
          thickness: WidgetStateProperty.all(0.0),
        ),
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (_, child) => DynamicLinksHandler(
        router: _router,
        child: child!,
      ),
    );
    // Wrap the entire MaterialApp in the offline indicator banner so
    // the "You're offline" notice overlays every screen in the app.
    // The banner is non-blocking — it just informs users that writes
    // are being queued and will sync when connectivity returns.
    return app; // OfflineIndicatorBanner temporarily removed
  }
}
