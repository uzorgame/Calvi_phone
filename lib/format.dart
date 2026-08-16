/// How numbers are set in this app.
library;

/// Thousands separated the way Ukrainian sets them.
///
/// The separator is a non-breaking space and has to be: one that wraps splits a
/// figure across two lines, and «2 066» read as «2» then «066» is a different
/// number. Written as an escape so the character is visible in the source
/// instead of looking like a plain space.
String thousands(int n) {
  final s = n.abs().toString();
  final out = StringBuffer(n < 0 ? '\u2212' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('\u00A0');
    out.write(s[i]);
  }
  return out.toString();
}
