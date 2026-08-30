import 'dart:async';
import 'dart:io';

/// Animated CLI loading indicator utility.
class LoadingProgress {
  static const List<String> _frames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  /// Runs an asynchronous [task] while displaying an animated loading spinner with [message].
  static Future<T> run<T>({
    required String message,
    required Future<T> Function() task,
    String? successMessage,
  }) async {
    final hasTerminal = stdout.hasTerminal;

    if (!hasTerminal) {
      stdout.writeln('⏳ $message');
      final result = await task();
      if (successMessage != null) {
        stdout.writeln('✅ $successMessage');
      }
      return result;
    }

    int frameIndex = 0;
    Timer? timer;

    // Hide terminal cursor
    stdout.write('\x1B[?25l');

    timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final frame = _frames[frameIndex % _frames.length];
      stdout.write('\r\x1B[K\x1B[36m$frame\x1B[0m $message');
      frameIndex++;
    });

    try {
      final result = await task();
      timer.cancel();
      // Restore cursor
      stdout.write('\x1B[?25h');
      final doneMsg = successMessage ?? message;
      stdout.writeln('\r\x1B[K\x1B[32m✔\x1B[0m $doneMsg');
      return result;
    } catch (e) {
      timer.cancel();
      // Restore cursor
      stdout.write('\x1B[?25h');
      stdout.writeln('\r\x1B[K\x1B[31m✖\x1B[0m $message (Failed)');
      rethrow;
    }
  }
}
