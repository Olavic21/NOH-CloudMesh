class LineFramer {
  LineFramer({this.maxLength = 1048576}) {
    if (maxLength < 0) {
      throw ArgumentError.value(maxLength, 'maxLength', 'must not be negative');
    }
  }

  final int maxLength;
  final List<int> _buffer = [];

  /// Ajoute les octets reçus et renvoie les lignes complètes, sans LF ni CR final.
  /// Les lignes vides sont ignorées.
  List<List<int>> add(List<int> bytes) {
    final lines = <List<int>>[];

    for (final byte in bytes) {
      if (byte == 0x0a) {
        if (_buffer.isNotEmpty && _buffer.last == 0x0d) {
          _buffer.removeLast();
        }
        if (_buffer.isNotEmpty) {
          lines.add(List<int>.of(_buffer));
        }
        _buffer.clear();
      } else {
        _buffer.add(byte);
        _checkLength();
      }
    }

    return lines;
  }

  void _checkLength() {
    final trailingCr = _buffer.isNotEmpty && _buffer.last == 0x0d ? 1 : 0;
    if (_buffer.length - trailingCr > maxLength) {
      _buffer.clear();
      throw FrameTooLargeException(maxLength);
    }
  }
}

class FrameTooLargeException implements Exception {
  const FrameTooLargeException(this.maxLength);

  final int maxLength;

  @override
  String toString() => 'Frame exceeds the maximum length of $maxLength bytes.';
}