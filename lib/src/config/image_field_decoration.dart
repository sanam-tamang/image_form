import 'package:flutter/material.dart';

/// All visual styling options for [ImageFormField] and [MultiImageFormField].
///
/// Deliberately separated from [ImageFieldConfig] so behaviour and
/// appearance stay independently swappable:
/// ```dart
/// ImageFieldDecoration(
///   placeholder: Icon(Icons.person, size: 48),
///   editIcon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
///   editIconBackgroundColor: Colors.black54,
///   border: Border.all(color: Colors.grey),
///   errorStyle: TextStyle(color: Colors.red, fontSize: 12),
/// )
/// ```
class ImageFieldDecoration {
  const ImageFieldDecoration({
    this.placeholder,
    this.loadingWidget,
    this.errorWidget,
    this.editIcon,
    this.editIconBackgroundColor,
    this.editIconPadding = const EdgeInsets.all(6),
    this.editIconBorderRadius = 20.0,
    this.overlayColor,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.backgroundColor,
    this.label,
    this.labelStyle,
    this.helperText,
    this.helperStyle,
    this.errorStyle,
    this.contentPadding = EdgeInsets.zero,
  });

  // ── Placeholder & Loading ─────────────────────────────────────────────────

  /// Shown when the field is [EmptyImageItem] — no image selected yet.
  /// Defaults to a centered camera icon if null.
  final Widget? placeholder;

  /// Shown while a network image is downloading.
  /// Defaults to a centered CircularProgressIndicator if null.
  final Widget? loadingWidget;

  /// Shown when a network image fails to load.
  /// Defaults to a centered error icon if null.
  final Widget? errorWidget;

  // ── Edit Icon ─────────────────────────────────────────────────────────────

  /// The icon shown in the edit overlay.
  /// Defaults to Icons.camera_alt wrapped in a white circle.
  final Widget? editIcon;

  /// Background color of the edit icon badge.
  /// Defaults to Colors.black54.
  final Color? editIconBackgroundColor;

  /// Padding inside the edit icon badge.
  final EdgeInsetsGeometry editIconPadding;

  /// Border radius of the edit icon badge circle.
  final double editIconBorderRadius;

  // ── Overlay ───────────────────────────────────────────────────────────────

  /// Semi-transparent color overlaid on the image when loading or disabled.
  /// Defaults to Colors.black26 during loading, transparent otherwise.
  final Color? overlayColor;

  // ── Border ────────────────────────────────────────────────────────────────

  /// Border drawn around the image widget in its normal state.
  final BoxBorder? border;

  /// Border drawn when the field is focused / hovered.
  final BoxBorder? focusedBorder;

  /// Border drawn when the field has a validation error.
  final BoxBorder? errorBorder;

  // ── Background ────────────────────────────────────────────────────────────

  /// Background color of the image container.
  /// Visible when the image does not fill the entire area.
  final Color? backgroundColor;

  // ── Label & Text ──────────────────────────────────────────────────────────

  /// Optional label shown above the field, like InputDecoration.label.
  final Widget? label;

  /// Style for [label] text if label is a [Text] widget.
  final TextStyle? labelStyle;

  /// Helper text shown below the field.
  final String? helperText;

  /// Style for [helperText].
  final TextStyle? helperStyle;

  /// Style for validation error text shown below the field.
  /// Defaults to Theme.of(context).colorScheme.error at 12sp.
  final TextStyle? errorStyle;

  // ── Spacing ───────────────────────────────────────────────────────────────

  /// Padding around the image container itself.
  final EdgeInsetsGeometry contentPadding;

  // ── copyWith ──────────────────────────────────────────────────────────────

  ImageFieldDecoration copyWith({
    Widget? placeholder,
    Widget? loadingWidget,
    Widget? errorWidget,
    Widget? editIcon,
    Color? editIconBackgroundColor,
    EdgeInsetsGeometry? editIconPadding,
    double? editIconBorderRadius,
    Color? overlayColor,
    BoxBorder? border,
    BoxBorder? focusedBorder,
    BoxBorder? errorBorder,
    Color? backgroundColor,
    Widget? label,
    TextStyle? labelStyle,
    String? helperText,
    TextStyle? helperStyle,
    TextStyle? errorStyle,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return ImageFieldDecoration(
      placeholder: placeholder ?? this.placeholder,
      loadingWidget: loadingWidget ?? this.loadingWidget,
      errorWidget: errorWidget ?? this.errorWidget,
      editIcon: editIcon ?? this.editIcon,
      editIconBackgroundColor:
          editIconBackgroundColor ?? this.editIconBackgroundColor,
      editIconPadding: editIconPadding ?? this.editIconPadding,
      editIconBorderRadius: editIconBorderRadius ?? this.editIconBorderRadius,
      overlayColor: overlayColor ?? this.overlayColor,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      errorBorder: errorBorder ?? this.errorBorder,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      label: label ?? this.label,
      labelStyle: labelStyle ?? this.labelStyle,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }
}
