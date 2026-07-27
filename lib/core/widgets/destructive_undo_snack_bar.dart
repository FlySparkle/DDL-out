import 'dart:async';

import 'package:flutter/material.dart';

const destructiveUndoDuration = Duration(seconds: 6);

void showDestructiveUndoSnackBar({
  required ScaffoldMessengerState messenger,
  required String message,
  required String Function(int seconds) undoLabel,
  required Future<void> Function() onUndo,
  Future<void> Function()? onExpired,
}) {
  messenger.hideCurrentSnackBar();
  var undone = false;
  late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  controller;
  controller = messenger.showSnackBar(
    SnackBar(
      duration: destructiveUndoDuration,
      content: _DestructiveUndoContent(
        message: message,
        undoLabel: undoLabel,
        onUndo: () async {
          if (undone) return;
          undone = true;
          controller.close();
          await onUndo();
        },
      ),
    ),
  );
  unawaited(
    controller.closed.then((_) async {
      if (!undone) await onExpired?.call();
    }),
  );
}

class _DestructiveUndoContent extends StatefulWidget {
  const _DestructiveUndoContent({
    required this.message,
    required this.undoLabel,
    required this.onUndo,
  });

  final String message;
  final String Function(int seconds) undoLabel;
  final Future<void> Function() onUndo;

  @override
  State<_DestructiveUndoContent> createState() =>
      _DestructiveUndoContentState();
}

class _DestructiveUndoContentState extends State<_DestructiveUndoContent> {
  Timer? _timer;
  var _remainingSeconds = destructiveUndoDuration.inSeconds;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remainingSeconds <= 1) return;
      setState(() => _remainingSeconds -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(widget.message, maxLines: 2, overflow: TextOverflow.fade),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: widget.onUndo,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: Text(widget.undoLabel(_remainingSeconds)),
        ),
      ],
    );
  }
}
