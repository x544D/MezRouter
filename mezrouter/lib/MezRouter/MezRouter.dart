import 'package:get/get.dart';

/// This works for both Named and None-named routing
class MRoute<T> {
  T route;
  dynamic args;
  Map<String, String>? params;

  MRoute({required this.route, this.args, this.params});

  bool isNamedRoute() => T is String;
}

/// This does not support NestedNavigation yet.
class MezRouter {
  static final List<MRoute> _navigationStack = <MRoute>[];
  // This will act as a lock, basically if there's any push/pop happening, we lock other functionalities to avoid race conditions
  static bool _isBusy = false;

  /// Shortcut to [Get.toNamed]
  static Future<Q?>? toNamed<Q>(
    String page, {
    dynamic arguments,
    // int? id, later on for nested routes
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    // TODO : Make sure that _isBusy is false!
    // if not we mark this current fcall as a delegate and await for it.
    _navigationStack.addIf(
      preventDuplicates && _navigationStack.last.route == page,
      MRoute(route: page, args: arguments, params: parameters),
    );

    _isBusy = true;
    final dynamic globalResult = Get.toNamed<Q>(
      page,
      arguments: arguments,
      parameters: parameters,
      preventDuplicates: preventDuplicates,
    )?.then((value) {
      return value;
    });
    _isBusy = false;

    return globalResult;
  }

  /// Get currentRoute on the stack! null if navigationStack is empty
  static MRoute? currentRoute() =>
      _navigationStack.isEmpty ? null : _navigationStack.last;

  /// This basically gives a route based on the [level] given.
  ///
  /// a [Level] is basically how many steps to go back from [this.currentRoute].
  ///
  /// exp : In the following navigation stack [home -> Settings -> UserInfo], so basically UserInfo was last in which means we are currently in [UserInfo] Route, and we wanna check what's the route on our navigation stack that is sitting behind UserInfo, so the use of our function will be like this : getRouteByLevel(level: 1).
  ///
  /// Note : calling getRouteByLevel(level:0) will simply return current route, which is basically a shortcut to [this.currentRoute]
  ///
  /// Note : Giving a level that is out of range, will return null.
  static MRoute? getRouteByLevel({required int level}) {
    // check if level is a correct level
    if (level >= _navigationStack.length) {
      return null;
    }
    return _navigationStack.reversed.toList()[level];
  }

  /// This checks if a route is in NavigationStack.
  static bool isRouteInStack<T>(T route) => _navigationStack
      .where((MRoute routeInstance) => routeInstance.route == route)
      .isNotEmpty;
}
