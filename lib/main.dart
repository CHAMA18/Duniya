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
import '/rbac/rbac.dart';

// kAppFontFamily is defined in flutter_flow_util.dart (imported above).
// It resolves to 'Inter' on web (CanvasKit-safe) and 'Satoshi' on native.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  // Initialise offline connectivity tracking as early as possible so
  // the banner reflects the correct state from the very first frame.
  OfflineConnectivityService().initialize();

  // Initialise offline sync service so Firestore pending-write
  // tracking is available from the first frame.
  OfflineSyncService().initialize();

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
  // On web: use Flutter's DEFAULT error handling. The original app
  // rendered correctly with CanvasKit despite the null-check errors —
  // they were just console noise. Custom handlers interfered with
  // Flutter's internal error recovery, causing the blank screen.

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
        // Auto-warm and sync tracking — re-enabled after fixing
        // the double-listener infinite rebuild loop in OfflineStatusChip.
        if (user?.loggedIn == true) {
          _onUserSignedIn();
        }
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
      // Guard: ensure both the user document and reference are available
      // before setting up sync tracking. The authenticatedUserStream can
      // fire before the Firestore UserRecord has been fetched.
      final userDoc = currentUserDocument;
      final userRef = currentUserReference;
      if (userDoc == null || userRef == null) {
        debugPrint('[main] _onUserSignedIn: user document not yet loaded, skipping sync setup');
        return;
      }
      // Watch the user's collections for pending writes.
      // This populates the OfflineStatusChip with real sync data.
      // Uses AccessControl.parentRefFromDoc (context-free variant)
      // instead of inline role == 'Owner' check.
      final ownerRef = AccessControl.parentRefFromDoc(userDoc, userRef);
      if (ownerRef != null) {
        OfflineSyncService().watchCollection(
          FirebaseFirestore.instance
              .collection('User')
              .doc(ownerRef.id)
              .collection('Pharmacy'),
        );
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
        fontFamily: kAppFontFamily,
        // Force Satoshi on EVERY Material text style slot so any widget
        // that doesn't go through FlutterFlowTheme.of(context) — default
        // Text(), AppBar title, Button labels, SnackBar, Dialog, etc. —
        // also renders in Satoshi.
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: kAppFontFamily),
          displayMedium: TextStyle(fontFamily: kAppFontFamily),
          displaySmall: TextStyle(fontFamily: kAppFontFamily),
          headlineLarge: TextStyle(fontFamily: kAppFontFamily),
          headlineMedium: TextStyle(fontFamily: kAppFontFamily),
          headlineSmall: TextStyle(fontFamily: kAppFontFamily),
          titleLarge: TextStyle(fontFamily: kAppFontFamily),
          titleMedium: TextStyle(fontFamily: kAppFontFamily),
          titleSmall: TextStyle(fontFamily: kAppFontFamily),
          bodyLarge: TextStyle(fontFamily: kAppFontFamily),
          bodyMedium: TextStyle(fontFamily: kAppFontFamily),
          bodySmall: TextStyle(fontFamily: kAppFontFamily),
          labelLarge: TextStyle(fontFamily: kAppFontFamily),
          labelMedium: TextStyle(fontFamily: kAppFontFamily),
          labelSmall: TextStyle(fontFamily: kAppFontFamily),
        ),
        primaryTextTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: kAppFontFamily),
          displayMedium: TextStyle(fontFamily: kAppFontFamily),
          displaySmall: TextStyle(fontFamily: kAppFontFamily),
          headlineLarge: TextStyle(fontFamily: kAppFontFamily),
          headlineMedium: TextStyle(fontFamily: kAppFontFamily),
          headlineSmall: TextStyle(fontFamily: kAppFontFamily),
          titleLarge: TextStyle(fontFamily: kAppFontFamily),
          titleMedium: TextStyle(fontFamily: kAppFontFamily),
          titleSmall: TextStyle(fontFamily: kAppFontFamily),
          bodyLarge: TextStyle(fontFamily: kAppFontFamily),
          bodyMedium: TextStyle(fontFamily: kAppFontFamily),
          bodySmall: TextStyle(fontFamily: kAppFontFamily),
          labelLarge: TextStyle(fontFamily: kAppFontFamily),
          labelMedium: TextStyle(fontFamily: kAppFontFamily),
          labelSmall: TextStyle(fontFamily: kAppFontFamily),
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
        fontFamily: kAppFontFamily,
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: kAppFontFamily),
          displayMedium: TextStyle(fontFamily: kAppFontFamily),
          displaySmall: TextStyle(fontFamily: kAppFontFamily),
          headlineLarge: TextStyle(fontFamily: kAppFontFamily),
          headlineMedium: TextStyle(fontFamily: kAppFontFamily),
          headlineSmall: TextStyle(fontFamily: kAppFontFamily),
          titleLarge: TextStyle(fontFamily: kAppFontFamily),
          titleMedium: TextStyle(fontFamily: kAppFontFamily),
          titleSmall: TextStyle(fontFamily: kAppFontFamily),
          bodyLarge: TextStyle(fontFamily: kAppFontFamily),
          bodyMedium: TextStyle(fontFamily: kAppFontFamily),
          bodySmall: TextStyle(fontFamily: kAppFontFamily),
          labelLarge: TextStyle(fontFamily: kAppFontFamily),
          labelMedium: TextStyle(fontFamily: kAppFontFamily),
          labelSmall: TextStyle(fontFamily: kAppFontFamily),
        ),
        primaryTextTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: kAppFontFamily),
          displayMedium: TextStyle(fontFamily: kAppFontFamily),
          displaySmall: TextStyle(fontFamily: kAppFontFamily),
          headlineLarge: TextStyle(fontFamily: kAppFontFamily),
          headlineMedium: TextStyle(fontFamily: kAppFontFamily),
          headlineSmall: TextStyle(fontFamily: kAppFontFamily),
          titleLarge: TextStyle(fontFamily: kAppFontFamily),
          titleMedium: TextStyle(fontFamily: kAppFontFamily),
          titleSmall: TextStyle(fontFamily: kAppFontFamily),
          bodyLarge: TextStyle(fontFamily: kAppFontFamily),
          bodyMedium: TextStyle(fontFamily: kAppFontFamily),
          bodySmall: TextStyle(fontFamily: kAppFontFamily),
          labelLarge: TextStyle(fontFamily: kAppFontFamily),
          labelMedium: TextStyle(fontFamily: kAppFontFamily),
          labelSmall: TextStyle(fontFamily: kAppFontFamily),
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
        child: child ?? const SizedBox.shrink(),
      ),
    );
    // Wrap the entire MaterialApp in the offline indicator banner so
    // the "You're offline" notice overlays every screen in the app.
    // The banner is non-blocking — it just informs users that writes
    // are being queued and will sync when connectivity returns.
    return OfflineIndicatorBanner(child: app);
  }
}
