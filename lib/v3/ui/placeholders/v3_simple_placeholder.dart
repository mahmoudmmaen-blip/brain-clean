import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design_constants.dart';
import '../../routing/v3_routes.dart';

class V3SimplePlaceholder extends StatelessWidget {
  const V3SimplePlaceholder({
    super.key,
    required this.title,
    this.routeKey,
  });

  final String title;
  final Key? routeKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: routeKey,
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(V3Routes.today);
            }
          },
        ),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
