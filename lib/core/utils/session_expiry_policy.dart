import 'package:shared_preferences/shared_preferences.dart';

/// Client-side "re-login after inactivity" policy.
///
/// Supabase keeps a user signed in indefinitely (the refresh token silently
/// renews the access token), and time-boxed sessions are a paid feature. So we
/// enforce the expiry ourselves without disrupting active users:
///
///  * When the app goes to the background we stamp [markBackgrounded].
///  * When it returns to the foreground (or cold-starts) we check
///    [hasExpiredWhileBackgrounded]; if more than [maxBackgroundDuration] has
///    passed we sign the user out and send them back to the login screen.
///
/// A user who keeps the app in the foreground is never interrupted, because the
/// timestamp is only written when the app actually leaves the foreground.
class SessionExpiryPolicy {
  SessionExpiryPolicy._();

  static const Duration maxBackgroundDuration = Duration(hours: 1);
  static const String _backgroundedAtKey = 'session_backgrounded_at_ms';

  /// Records the moment the app left the foreground. Persisted so it also
  /// survives the process being killed while backgrounded (cold start).
  static Future<void> markBackgrounded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _backgroundedAtKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// True when a background stamp exists and the gap since then exceeds
  /// [maxBackgroundDuration]. Returns false when there is no stamp (e.g. a fresh
  /// login), so users are never logged out prematurely.
  static Future<bool> hasExpiredWhileBackgrounded() async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundedAtMs = prefs.getInt(_backgroundedAtKey);
    if (backgroundedAtMs == null) return false;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(backgroundedAtMs),
    );
    return elapsed >= maxBackgroundDuration;
  }

  /// Clears the stamp once the foreground gap has been evaluated, so the next
  /// check only measures the most recent background period.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backgroundedAtKey);
  }
}
