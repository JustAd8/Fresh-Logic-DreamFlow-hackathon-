import 'package:flutter/material.dart';

/// Device types based on screen width
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive layout helper that adapts UI based on screen size
class ResponsiveLayout {
  /// Get the device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile (smartphone)
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Get responsive value based on device type
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get max content width for better readability on large screens
  static double getMaxContentWidth(BuildContext context) {
    return value(
      context,
      mobile: double.infinity,
      tablet: 700,
      desktop: 1200,
    );
  }

  /// Get horizontal padding based on screen size
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context,
        mobile: 16,
        tablet: 32,
        desktop: 48,
      ),
    );
  }

  /// Get grid columns count based on screen size
  static int getGridColumns(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    return value(
      context,
      mobile: mobile ?? 1,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
    );
  }

  /// Get grid aspect ratio based on screen size
  static double getGridAspectRatio(BuildContext context) {
    return value(
      context,
      mobile: 0.85,
      tablet: 0.9,
      desktop: 1.0,
    );
  }

  /// Build responsive widget based on device type
  static Widget builder(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive font size scale factor
  static double getFontScale(BuildContext context) {
    return value(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.15,
    );
  }

  /// Center content with max width constraint
  static Widget centerConstrainedContent(
    BuildContext context, {
    required Widget child,
    double? maxWidth,
  }) {
    final effectiveMaxWidth = maxWidth ?? getMaxContentWidth(context);
    if (effectiveMaxWidth == double.infinity) {
      return child;
    }
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }

  /// Get card elevation based on screen size
  static double getCardElevation(BuildContext context) {
    return value(
      context,
      mobile: 0,
      tablet: 1,
      desktop: 2,
    );
  }

  /// Get spacing value based on screen size
  static double getSpacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.25,
      desktop: desktop ?? tablet ?? mobile * 1.5,
    );
  }

  /// Get icon size based on screen size
  static double getIconSize(BuildContext context) {
    return value(
      context,
      mobile: 24,
      tablet: 28,
      desktop: 32,
    );
  }

  /// Get button height based on screen size
  static double getButtonHeight(BuildContext context) {
    return value(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }

  /// Check if should show side navigation (drawer on mobile, rail on larger)
  static bool shouldShowNavigationRail(BuildContext context) {
    return !isMobile(context);
  }

  /// Get dialog/modal max width
  static double getDialogMaxWidth(BuildContext context) {
    return value(
      context,
      mobile: MediaQuery.of(context).size.width * 0.9,
      tablet: 500,
      desktop: 600,
    );
  }

  /// Get image/card border radius based on screen size
  static double getBorderRadius(BuildContext context) {
    return value(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveLayout.getDeviceType(this);
  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
  
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) => ResponsiveLayout.value(this, mobile: mobile, tablet: tablet, desktop: desktop);
}
