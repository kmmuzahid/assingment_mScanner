// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i9;

import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:pinlink/coreFeature/home/home_screen.dart' as _i1;
import 'package:pinlink/coreFeature/onboarding_screen.dart' as _i2;
import 'package:pinlink/coreFeature/saved_files/saved_file_detail_screen.dart'
    as _i3;
import 'package:pinlink/coreFeature/saved_files/saved_files_screen.dart' as _i4;
import 'package:pinlink/coreFeature/scanner/scanner_screen.dart' as _i5;
import 'package:pinlink/coreFeature/splash/splash_screen.dart' as _i6;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.OnboardingScreen]
class OnboardingRoute extends _i7.PageRouteInfo<void> {
  const OnboardingRoute({List<_i7.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i3.SavedFileDetailScreen]
class SavedFileDetailRoute extends _i7.PageRouteInfo<SavedFileDetailRouteArgs> {
  SavedFileDetailRoute({
    _i8.Key? key,
    required _i9.File file,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         SavedFileDetailRoute.name,
         args: SavedFileDetailRouteArgs(key: key, file: file),
         initialChildren: children,
       );

  static const String name = 'SavedFileDetailRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SavedFileDetailRouteArgs>();
      return _i3.SavedFileDetailScreen(key: args.key, file: args.file);
    },
  );
}

class SavedFileDetailRouteArgs {
  const SavedFileDetailRouteArgs({this.key, required this.file});

  final _i8.Key? key;

  final _i9.File file;

  @override
  String toString() {
    return 'SavedFileDetailRouteArgs{key: $key, file: $file}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SavedFileDetailRouteArgs) return false;
    return key == other.key && file == other.file;
  }

  @override
  int get hashCode => key.hashCode ^ file.hashCode;
}

/// generated route for
/// [_i4.SavedFilesScreen]
class SavedFilesRoute extends _i7.PageRouteInfo<void> {
  const SavedFilesRoute({List<_i7.PageRouteInfo>? children})
    : super(SavedFilesRoute.name, initialChildren: children);

  static const String name = 'SavedFilesRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.SavedFilesScreen();
    },
  );
}

/// generated route for
/// [_i5.ScannerScreen]
class ScannerRoute extends _i7.PageRouteInfo<void> {
  const ScannerRoute({List<_i7.PageRouteInfo>? children})
    : super(ScannerRoute.name, initialChildren: children);

  static const String name = 'ScannerRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i5.ScannerScreen();
    },
  );
}

/// generated route for
/// [_i6.SplashScreen]
class SplashRoute extends _i7.PageRouteInfo<void> {
  const SplashRoute({List<_i7.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.SplashScreen();
    },
  );
}
