import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

import '/vmi/dashboard/vmi_dashboard_widget.dart';
import '/vmi/stock_balances/stock_balances_widget.dart';
import '/vmi/stock_movements/stock_movements_widget.dart';
import '/vmi/product_master/product_master_widget.dart';
import '/vmi/goods_received/goods_received_widget.dart';
import '/vmi/goods_received_detail/goods_received_detail_widget.dart';
import '/vmi/sales_vmi/sales_vmi_widget.dart';
import '/vmi/stock_counts/stock_counts_widget.dart';
import '/vmi/stock_count_detail/stock_count_detail_widget.dart';
import '/vmi/batches/batches_widget.dart';
import '/vmi/alerts/low_stock_alerts_widget.dart';
import '/vmi/replenishment/replenishment_widget.dart';
import '/vmi/outlets/outlets_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';
export '/backend/firebase_dynamic_links/firebase_dynamic_links.dart'
    show generateCurrentPageLink;

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => _RouteErrorBuilder(
        state: state,
        child:
            appStateNotifier.loggedIn ? WelcomeWidget() : RegisterUniWidget(),
      ),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? WelcomeWidget() : RegisterUniWidget(),
        ),
        FFRoute(
          name: CreatePharmacyWidget.routeName,
          path: CreatePharmacyWidget.routePath,
          requireAuth: true,
          builder: (context, params) => CreatePharmacyWidget(),
        ),
        FFRoute(
          name: LoginUniWidget.routeName,
          path: LoginUniWidget.routePath,
          builder: (context, params) => LoginUniWidget(),
        ),
        FFRoute(
          name: RegisterUniWidget.routeName,
          path: RegisterUniWidget.routePath,
          builder: (context, params) => RegisterUniWidget(),
        ),
        FFRoute(
          name: StoreInventoryWidget.routeName,
          path: StoreInventoryWidget.routePath,
          builder: (context, params) => StoreInventoryWidget(),
        ),
        FFRoute(
          name: InventoryCategoryWidget.routeName,
          path: InventoryCategoryWidget.routePath,
          requireAuth: true,
          builder: (context, params) => InventoryCategoryWidget(
            category: params.getParam(
              'category',
              ParamType.String,
            ),
            pharmacy: params.getParam(
              'pharmacy',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ItemDetailsWidget.routeName,
          path: ItemDetailsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ItemDetailsWidget(
            item: params.getParam(
              'item',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['User', 'Stock'],
            ),
          ),
        ),
        FFRoute(
          name: ProfilUniWidget.routeName,
          path: ProfilUniWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ProfilUniWidget(),
        ),
        FFRoute(
          name: HumanResourceUniWidget.routeName,
          path: HumanResourceUniWidget.routePath,
          builder: (context, params) => HumanResourceUniWidget(),
        ),
        FFRoute(
          name: OnboardingUniWidget.routeName,
          path: OnboardingUniWidget.routePath,
          builder: (context, params) => OnboardingUniWidget(),
        ),
        FFRoute(
          name: BMICalcWidget.routeName,
          path: BMICalcWidget.routePath,
          requireAuth: true,
          builder: (context, params) => BMICalcWidget(),
        ),
        FFRoute(
          name: BMIResultWidget.routeName,
          path: BMIResultWidget.routePath,
          requireAuth: true,
          builder: (context, params) => BMIResultWidget(),
        ),
        FFRoute(
          name: AiAssistantWidget.routeName,
          path: AiAssistantWidget.routePath,
          requireAuth: true,
          builder: (context, params) => AiAssistantWidget(),
        ),
        FFRoute(
          name: PharmacyToolsWidget.routeName,
          path: PharmacyToolsWidget.routePath,
          builder: (context, params) => PharmacyToolsWidget(),
        ),
        FFRoute(
          name: FinancesWidget.routeName,
          path: FinancesWidget.routePath,
          builder: (context, params) => FinancesWidget(),
        ),
        FFRoute(
          name: PendingApprovalsWidget.routeName,
          path: PendingApprovalsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PendingApprovalsWidget(),
        ),
        FFRoute(
          name: ManagePharmacyWidget.routeName,
          path: ManagePharmacyWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ManagePharmacyWidget(
            pharmacyName: params.getParam(
              'pharmacyName',
              ParamType.String,
            ),
            pharmacyAddress: params.getParam(
              'pharmacyAddress',
              ParamType.String,
            ),
            pharmacyRef: params.getParam(
              'pharmacyRef',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PointOfSalesWidget.routeName,
          path: PointOfSalesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PointOfSalesWidget(
            pharm: params.getParam(
              'pharm',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: WelcomeWidget.routeName,
          path: WelcomeWidget.routePath,
          builder: (context, params) => WelcomeWidget(),
        ),
        FFRoute(
          name: CreateUserCompleteRegistrationWidget.routeName,
          path: CreateUserCompleteRegistrationWidget.routePath,
          requireAuth: true,
          builder: (context, params) => CreateUserCompleteRegistrationWidget(),
        ),
        FFRoute(
          name: MapsWidget.routeName,
          path: MapsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => MapsWidget(),
        ),
        FFRoute(
          name: BillingMobileWidget.routeName,
          path: BillingMobileWidget.routePath,
          builder: (context, params) => BillingMobileWidget(),
        ),
        FFRoute(
          name: ResetPassWidget.routeName,
          path: ResetPassWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ResetPassWidget(),
        ),
        FFRoute(
          name: SubscriptionWidget.routeName,
          path: SubscriptionWidget.routePath,
          requireAuth: true,
          builder: (context, params) => SubscriptionWidget(),
        ),
        FFRoute(
          name: AddProductWidget.routeName,
          path: AddProductWidget.routePath,
          requireAuth: true,
          builder: (context, params) => AddProductWidget(
            pharm: params.getParam(
              'pharm',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: AddUserWidget.routeName,
          path: AddUserWidget.routePath,
          builder: (context, params) => AddUserWidget(),
        ),
        FFRoute(
          name: StoresWidget.routeName,
          path: StoresWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StoresWidget(),
        ),
        FFRoute(
          name: AddstoresWidget.routeName,
          path: AddstoresWidget.routePath,
          requireAuth: true,
          builder: (context, params) => AddstoresWidget(),
        ),
        FFRoute(
          name: NotificationsMobileWidget.routeName,
          path: NotificationsMobileWidget.routePath,
          builder: (context, params) => NotificationsMobileWidget(),
        ),
        FFRoute(
          name: LanguageWidget.routeName,
          path: LanguageWidget.routePath,
          builder: (context, params) => LanguageWidget(),
        ),
        FFRoute(
          name: ServiceLevelAgreementWidget.routeName,
          path: ServiceLevelAgreementWidget.routePath,
          builder: (context, params) => ServiceLevelAgreementWidget(),
        ),
        FFRoute(
          name: DrugdetailsWidget.routeName,
          path: DrugdetailsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => DrugdetailsWidget(),
        ),
        FFRoute(
          name: ResetPasswordUniWidget.routeName,
          path: ResetPasswordUniWidget.routePath,
          builder: (context, params) => ResetPasswordUniWidget(),
        ),
        FFRoute(
          name: RequestWidget.routeName,
          path: RequestWidget.routePath,
          requireAuth: true,
          builder: (context, params) => RequestWidget(),
        ),
        FFRoute(
          name: RefundPolWidget.routeName,
          path: RefundPolWidget.routePath,
          builder: (context, params) => RefundPolWidget(),
        ),
        FFRoute(
          name: TandCsMobileWidget.routeName,
          path: TandCsMobileWidget.routePath,
          requireAuth: true,
          builder: (context, params) => TandCsMobileWidget(),
        ),
        FFRoute(
          name: MyPharmaciesWidget.routeName,
          path: MyPharmaciesWidget.routePath,
          builder: (context, params) => MyPharmaciesWidget(),
        ),
        FFRoute(
          name: WebCreateUserWidget.routeName,
          path: WebCreateUserWidget.routePath,
          requireAuth: true,
          builder: (context, params) => WebCreateUserWidget(
            websiteUrl: params.getParam(
              'websiteUrl',
              ParamType.String,
            ),
            email: params.getParam(
              'email',
              ParamType.String,
            ),
            pharmId: params.getParam(
              'pharmId',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['User', 'Pharmacy'],
            ),
          ),
        ),
        FFRoute(
          name: HomeWidget.routeName,
          path: HomeWidget.routePath,
          builder: (context, params) => HomeWidget(),
        ),
        FFRoute(
          name: SalesItemsWidget.routeName,
          path: SalesItemsWidget.routePath,
          builder: (context, params) => SalesItemsWidget(
            sale: params.getParam(
              'sale',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['User', 'Sales'],
            ),
          ),
        ),
        FFRoute(
          name: EditstoresWidget.routeName,
          path: EditstoresWidget.routePath,
          requireAuth: true,
          builder: (context, params) => EditstoresWidget(
            pharmId: params.getParam(
              'pharmId',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['User', 'Pharmacy'],
            ),
          ),
        ),
        FFRoute(
          name: SettingsWidget.routeName,
          path: SettingsWidget.routePath,
          builder: (context, params) => SettingsWidget(),
        ),
        FFRoute(
          name: NotificationsWidget.routeName,
          path: NotificationsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => NotificationsWidget(),
        ),
        FFRoute(
          name: StaffRegisterWidget.routeName,
          path: StaffRegisterWidget.routePath,
          builder: (context, params) => StaffRegisterWidget(
            staffId: params.getParam(
              'staffId',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Staff'],
            ),
          ),
        ),
        FFRoute(
          name: StaffLoginWidget.routeName,
          path: StaffLoginWidget.routePath,
          builder: (context, params) => StaffLoginWidget(
            staffId: params.getParam(
              'staffId',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Staff'],
            ),
          ),
        ),
        FFRoute(
          name: PharmacyInventoryWidget.routeName,
          path: PharmacyInventoryWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PharmacyInventoryWidget(
            pharmacy: params.getParam(
              'pharmacy',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SubscriptionFailedWidget.routeName,
          path: SubscriptionFailedWidget.routePath,
          builder: (context, params) => SubscriptionFailedWidget(),
        ),
        FFRoute(
          name: SubscriptionSuccessWidget.routeName,
          path: SubscriptionSuccessWidget.routePath,
          builder: (context, params) => SubscriptionSuccessWidget(),
        ),
        FFRoute(
          name: AwaitingPaymentWidget.routeName,
          path: AwaitingPaymentWidget.routePath,
          builder: (context, params) => AwaitingPaymentWidget(),
        ),
        FFRoute(
          name: ViewUserWidget.routeName,
          path: ViewUserWidget.routePath,
          builder: (context, params) => ViewUserWidget(
            staffRef: params.getParam(
              'staffRef',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Staff'],
            ),
          ),
        ),
        FFRoute(
          name: UpdateSubscriptionWidget.routeName,
          path: UpdateSubscriptionWidget.routePath,
          requireAuth: true,
          builder: (context, params) => UpdateSubscriptionWidget(),
        ),
        FFRoute(
          name: InventoryDetailsWidget.routeName,
          path: InventoryDetailsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => InventoryDetailsWidget(
            stock: params.getParam(
              'stock',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['User', 'Stock'],
            ),
          ),
        ),
        FFRoute(
          name: StaffDetailsWidget.routeName,
          path: StaffDetailsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StaffDetailsWidget(
            staff: params.getParam(
              'staff',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['Staff'],
            ),
          ),
        ),
        // VMI Routes
        FFRoute(
          name: VMIDashboardWidget.routeName,
          path: VMIDashboardWidget.routePath,
          builder: (context, params) => VMIDashboardWidget(),
        ),
        FFRoute(
          name: StockBalancesWidget.routeName,
          path: StockBalancesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StockBalancesWidget(
            pharmacy: params.getParam(
              'pharmacy',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: StockMovementsWidget.routeName,
          path: StockMovementsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StockMovementsWidget(),
        ),
        FFRoute(
          name: ProductMasterWidget.routeName,
          path: ProductMasterWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ProductMasterWidget(),
        ),
        FFRoute(
          name: GoodsReceivedWidget.routeName,
          path: GoodsReceivedWidget.routePath,
          requireAuth: true,
          builder: (context, params) => GoodsReceivedWidget(),
        ),
        FFRoute(
          name: GoodsReceivedDetailWidget.routeName,
          path: GoodsReceivedDetailWidget.routePath,
          requireAuth: true,
          builder: (context, params) => GoodsReceivedDetailWidget(
            docRef: params.getParam(
              'docRef',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: SalesVMIWidget.routeName,
          path: SalesVMIWidget.routePath,
          requireAuth: true,
          builder: (context, params) => SalesVMIWidget(
            pharmacy: params.getParam(
              'pharmacy',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: StockCountsWidget.routeName,
          path: StockCountsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StockCountsWidget(),
        ),
        FFRoute(
          name: StockCountDetailWidget.routeName,
          path: StockCountDetailWidget.routePath,
          requireAuth: true,
          builder: (context, params) => StockCountDetailWidget(
            docRef: params.getParam(
              'docRef',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: BatchesWidget.routeName,
          path: BatchesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => BatchesWidget(),
        ),
        FFRoute(
          name: LowStockAlertsWidget.routeName,
          path: LowStockAlertsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => LowStockAlertsWidget(),
        ),
        FFRoute(
          name: ReplenishmentWidget.routeName,
          path: ReplenishmentWidget.routePath,
          requireAuth: true,
          builder: (context, params) => ReplenishmentWidget(),
        ),
        FFRoute(
          name: OutletsWidget.routeName,
          path: OutletsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => OutletsWidget(),
        ),
        FFRoute(
          name: DuniyaStockBalancesWidget.routeName,
          path: DuniyaStockBalancesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => DuniyaStockBalancesWidget(),
        ),
        FFRoute(
          name: DuniyaPharmaciesWidget.routeName,
          path: DuniyaPharmaciesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => DuniyaPharmaciesWidget(),
        ),
        FFRoute(
          name: OnboardingRequestsWidget.routeName,
          path: OnboardingRequestsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => OnboardingRequestsWidget(),
        ),
        FFRoute(
          name: NetworkAnalyticsWidget.routeName,
          path: NetworkAnalyticsWidget.routePath,
          requireAuth: true,
          builder: (context, params) => NetworkAnalyticsWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/registerUni';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 100.0,
                    height: 100.0,
                    child: SpinKitRing(
                      color: FlutterFlowTheme.of(context).primary,
                      size: 100.0,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  name: state.name,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey, name: state.name, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 0),
      );
}

class _RouteErrorBuilder extends StatefulWidget {
  const _RouteErrorBuilder({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  final GoRouterState state;
  final Widget child;

  @override
  State<_RouteErrorBuilder> createState() => _RouteErrorBuilderState();
}

class _RouteErrorBuilderState extends State<_RouteErrorBuilder> {
  @override
  void initState() {
    super.initState();

    // Handle erroneous links from Firebase Dynamic Links.

    String? location;

    /*
    Handle `links` routes that have dynamic-link entangled with deep-link 
    */
    if (widget.state.uri.toString().startsWith('/link') &&
        widget.state.uri.queryParameters.containsKey('deep_link_id')) {
      final deepLinkId = widget.state.uri.queryParameters['deep_link_id'];
      if (deepLinkId != null) {
        final deepLinkUri = Uri.parse(deepLinkId);
        final link = deepLinkUri.toString();
        final host = deepLinkUri.host;
        location = link.split(host).last;
      }
    }

    if (widget.state.uri.toString().startsWith('/link') &&
        widget.state.uri.toString().contains('request_ip_version')) {
      location = '/';
    }

    if (location != null) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => context.go(location!));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
