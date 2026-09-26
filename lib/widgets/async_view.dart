import 'package:flutter/material.dart';

/// Generic loading / error / empty / data state wrapper for FutureBuilders
/// used across the read-only community screens.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.future,
    required this.builder,
    this.isEmpty,
    this.emptyMessage = '표시할 내용이 없습니다.',
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    '데이터를 불러오지 못했습니다.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || (isEmpty != null && isEmpty!(data))) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
            ),
          );
        }
        return builder(context, data);
      },
    );
  }
}
