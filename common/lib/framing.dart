/// Framer pour le protocole Length-Prefix Framing.
///
/// Format : [4 octets longueur Big Endian] [Corps JSON en UTF-8]
///
/// Ce framer gère :
/// - Les messages fragmentés sur plusieurs lectures
/// - Plusieurs messages dans un même bloc
/// - Les messages incomplets
class LengthPrefixFramer {
  LengthPrefixFramer({this.maxLength = 1048576}) {
    if (maxLength < 0) {
      throw ArgumentError.value(maxLength, 'maxLength', 'must not be negative');
    }
  }

  /// Taille maximale d'un message en octets
  final int maxLength;

  /// Buffer pour stocker les octets en attente
  final List<int> _buffer = [];

  /// État de lecture : true = on lit la longueur, false = on lit le corps
  bool _readingLength = true;

  /// Longueur du message en cours de lecture
  int _messageLength = 0;

  /// Ajoute des octets reçus et retourne les messages complets.
  ///
  /// Chaque message retourné est une liste d'octets (le corps JSON sans l'en-tête).
  List<List<int>> add(List<int> bytes) {
    final messages = <List<int>>[];

    _buffer.addAll(bytes);

    while (_buffer.isNotEmpty) {
      if (_readingLength) {
        // On a besoin de 4_octets pour lire la longueur
        if (_buffer.length < 4) {
          break; // Pas assez de données, attendre la suite
        }

        // Lire les 4 premiers octets comme un entier Big Endian
        _messageLength = _readBigEndianUint32(_buffer.sublist(0, 4));

        // Vérifier que la longueur est raisonnable
        if (_messageLength > maxLength) {
          _buffer.clear();
          _readingLength = true;
          throw FrameTooLargeException(maxLength);
        }

        if (_messageLength == 0) {
          // Message vide, on retire les 4 octets et on continue
          _buffer.removeRange(0, 4);
          continue;
        }

        // Retirer les 4 octets de longueur du buffer
        _buffer.removeRange(0, 4);
        _readingLength = false;
      } else {
        // On lit le corps du message
        if (_buffer.length < _messageLength) {
          break; // Pas assez de données pour le corps complet
        }

        // Extraire le message complet
        final message = _buffer.sublist(0, _messageLength);
        messages.add(message);

        // Retirer le message du buffer
        _buffer.removeRange(0, _messageLength);

        // Reprendre la lecture de la longueur pour le prochain message
        _readingLength = true;
        _messageLength = 0;
      }
    }

    return messages;
  }

  /// Lit un entier non signé 32 bits en Big Endian depuis 4 octets.
  int _readBigEndianUint32(List<int> bytes) {
    return (bytes[0] << 24) |
           (bytes[1] << 16) |
           (bytes[2] << 8) |
           bytes[3];
  }

  /// Réinitialise le framer (utile après une erreur ou une reconnexion).
  void reset() {
    _buffer.clear();
    _readingLength = true;
    _messageLength = 0;
  }
}

/// Exception levée quand un message dépasse la taille maximale.
class FrameTooLargeException implements Exception {
  const FrameTooLargeException(this.maxLength);

  final int maxLength;

  @override
  String toString() => 'Frame exceeds the maximum length of $maxLength bytes.';
}

/// Encode un message avec le préfixe de longueur.
///
/// Retourne une liste d'octets : [4 octets longueur Big Endian] [corps]
List<int> encodeFrame(List<int> body) {
  final lengthBytes = <int>[
    (body.length >> 24) & 0xFF,
    (body.length >> 16) & 0xFF,
    (body.length >> 8) & 0xFF,
    body.length & 0xFF,
  ];
  return [...lengthBytes, ...body];
}