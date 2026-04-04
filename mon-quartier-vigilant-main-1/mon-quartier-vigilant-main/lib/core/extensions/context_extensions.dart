import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  bool get isCompact => MediaQuery.sizeOf(this).width < 720;

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: isCompact ? 16 : 20,
      );
}