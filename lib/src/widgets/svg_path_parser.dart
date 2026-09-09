import 'dart:ui';
import 'dart:math';

/// Minimal SVG path data parser.
///
/// Handles: M, m, L, l, C, c, S, s, Q, q, T, t, A, a, H, h, V, v, Z, z
class SvgPathParser {
  final String _d;
  int _pos = 0;

  SvgPathParser(this._d);

  /// Parse the SVG path data string into a Flutter [Path].
  static Path parse(String d) {
    return SvgPathParser(d)._parse();
  }

  Path _parse() {
    final path = Path();
    _pos = 0;
    String? command;

    while (_pos < _d.length) {
      _skipWhitespace();
      if (_pos >= _d.length) break;

      final c = _d[_pos];
      if (c == ',' || c == '-') {
        // Continuation of previous command
      } else       if (RegExp(r'[A-Za-z]').hasMatch(c)) {
        command = c;
        _pos++;
      }

      if (command == null) {
        _pos++;
        continue;
      }

      switch (command) {
        case 'M':
          _moveTo(path, relative: false);
          command = 'L'; // Subsequent coords are lineTo
          break;
        case 'm':
          _moveTo(path, relative: true);
          command = 'l';
          break;
        case 'L':
          _lineTo(path, relative: false);
          break;
        case 'l':
          _lineTo(path, relative: true);
          break;
        case 'H':
          _hLine(path, relative: false);
          break;
        case 'h':
          _hLine(path, relative: true);
          break;
        case 'V':
          _vLine(path, relative: false);
          break;
        case 'v':
          _vLine(path, relative: true);
          break;
        case 'C':
          _cubicTo(path, relative: false);
          break;
        case 'c':
          _cubicTo(path, relative: true);
          break;
        case 'S':
          _smoothCubic(path, relative: false);
          break;
        case 's':
          _smoothCubic(path, relative: true);
          break;
        case 'Q':
          _quadTo(path, relative: false);
          break;
        case 'q':
          _quadTo(path, relative: true);
          break;
        case 'T':
          _smoothQuad(path, relative: false);
          break;
        case 't':
          _smoothQuad(path, relative: true);
          break;
        case 'A':
          _arcTo(path, relative: false);
          break;
        case 'a':
          _arcTo(path, relative: true);
          break;
        case 'Z':
        case 'z':
          path.close();
          break;
        default:
          _pos++;
          break;
      }
    }

    return path;
  }

  double _lastX = 0, _lastY = 0;
  double _lastCx = 0, _lastCy = 0;

  void _skipWhitespace() {
    while (_pos < _d.length &&
        (' \t\n\r'.contains(_d[_pos]) || _d[_pos] == ',')) {
      _pos++;
    }
  }

  double _readNum() {
    _skipWhitespace();
    if (_pos >= _d.length) return 0;

    final start = _pos;
    if (_d[_pos] == '-' || _d[_pos] == '+') _pos++;
    while (_pos < _d.length &&
        (_d[_pos].contains(RegExp(r'[0-9.]')))) {
      _pos++;
    }
    if (start == _pos) return 0;
    return double.tryParse(_d.substring(start, _pos)) ?? 0;
  }

  void _moveTo(Path path, {required bool relative}) {
    final x = _readNum();
    final y = _readNum();
    final px = relative ? _lastX + x : x;
    final py = relative ? _lastY + y : y;
    path.moveTo(px, py);
    _lastX = px;
    _lastY = py;
  }

  void _lineTo(Path path, {required bool relative}) {
    final x = _readNum();
    final y = _readNum();
    final px = relative ? _lastX + x : x;
    final py = relative ? _lastY + y : y;
    path.lineTo(px, py);
    _lastX = px;
    _lastY = py;
  }

  void _hLine(Path path, {required bool relative}) {
    final x = _readNum();
    final px = relative ? _lastX + x : x;
    path.lineTo(px, _lastY);
    _lastX = px;
  }

  void _vLine(Path path, {required bool relative}) {
    final y = _readNum();
    final py = relative ? _lastY + y : y;
    path.lineTo(_lastX, py);
    _lastY = py;
  }

  void _cubicTo(Path path, {required bool relative}) {
    final x1 = _readNum(), y1 = _readNum();
    final x2 = _readNum(), y2 = _readNum();
    final x = _readNum(), y = _readNum();
    final ox = relative ? _lastX : 0;
    final oy = relative ? _lastY : 0;
    path.cubicTo(x1 + ox, y1 + oy, x2 + ox, y2 + oy, x + ox, y + oy);
    _lastCx = x2 + ox;
    _lastCy = y2 + oy;
    _lastX = x + ox;
    _lastY = y + oy;
  }

  void _smoothCubic(Path path, {required bool relative}) {
    final x2 = _readNum(), y2 = _readNum();
    final x = _readNum(), y = _readNum();
    final ox = relative ? _lastX : 0;
    final oy = relative ? _lastY : 0;
    final cx = 2 * _lastX - _lastCx;
    final cy = 2 * _lastY - _lastCy;
    path.cubicTo(cx, cy, x2 + ox, y2 + oy, x + ox, y + oy);
    _lastCx = x2 + ox;
    _lastCy = y2 + oy;
    _lastX = x + ox;
    _lastY = y + oy;
  }

  void _quadTo(Path path, {required bool relative}) {
    final x1 = _readNum(), y1 = _readNum();
    final x = _readNum(), y = _readNum();
    final ox = relative ? _lastX : 0;
    final oy = relative ? _lastY : 0;
    path.quadraticBezierTo(x1 + ox, y1 + oy, x + ox, y + oy);
    _lastCx = x1 + ox;
    _lastCy = y1 + oy;
    _lastX = x + ox;
    _lastY = y + oy;
  }

  void _smoothQuad(Path path, {required bool relative}) {
    final x = _readNum(), y = _readNum();
    final ox = relative ? _lastX : 0;
    final oy = relative ? _lastY : 0;
    final cx = 2 * _lastX - _lastCx;
    final cy = 2 * _lastY - _lastCy;
    path.quadraticBezierTo(cx, cy, x + ox, y + oy);
    _lastX = x + ox;
    _lastY = y + oy;
  }

  void _arcTo(Path path, {required bool relative}) {
    final rx = _readNum().abs();
    final ry = _readNum().abs();
    final rotation = _readNum() * pi / 180;
    final largeArc = _readNum() != 0;
    final sweep = _readNum() != 0;
    final x = _readNum(), y = _readNum();
    final ox = relative ? _lastX : 0;
    final oy = relative ? _lastY : 0;
    final endX = x + ox;
    final endY = y + oy;

    if (rx == 0 || ry == 0) {
      path.lineTo(endX, endY);
    } else {
      // Convert endpoint to center parameterization (simplified)
      final cosR = cos(rotation);
      final sinR = sin(rotation);
      final dx = (endX - _lastX) / 2;
      final dy = (endY - _lastY) / 2;
      final x1p = cosR * dx + sinR * dy;
      final y1p = -sinR * dx + cosR * dy;

      var ratio = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
      if (ratio > 1) {
        ratio = 1;
      }
      final s = ratio <= 1 ? sqrt(1 - ratio) : 0;
      final factor = (largeArc == sweep ? -1 : 1) * s;

      final cxp = -factor * rx * y1p / ry;
      final cyp = factor * ry * x1p / rx;

      final cx2 = cosR * cxp - sinR * cyp + (_lastX + endX) / 2;
      final cy2 = sinR * cxp + cosR * cyp + (_lastY + endY) / 2;

      final startAngle = atan2(y1p - cyp, x1p - cxp);
      final endAngle = atan2(-y1p - cyp, -x1p - cxp);
      final sweepAngle = sweep ? endAngle - startAngle : endAngle - startAngle;

      path.arcTo(
        Rect.fromCenter(
          center: Offset(cx2, cy2),
          width: rx * 2,
          height: ry * 2,
        ),
        startAngle,
        sweepAngle,
        false,
      );
    }

    _lastX = endX;
    _lastY = endY;
  }
}
