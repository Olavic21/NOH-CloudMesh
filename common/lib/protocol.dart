/// Définitions du protocole de communication TCP.
library;

/// Actions possibles dans les requêtes.
enum RequestAction {
  login('LOGIN'),
  logout('LOGOUT'),
  getProfile('GET_PROFILE'),
  updateProfile('UPDATE_PROFILE'),
  getMyRequests('GET_MY_REQUESTS'),
  submitRequest('SUBMIT_REQUEST'),
  updateRequest('UPDATE_REQUEST'),
  getNotifications('GET_NOTIFICATIONS'),
  acknowledgeNotification('ACKNOWLEDGE_NOTIFICATION');

  final String value;
  const RequestAction(this.value);

  static RequestAction fromString(String value) {
    return RequestAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => throw ArgumentError('Invalid action: $value'),
    );
  }
}

/// Types de messages.
enum MessageType {
  request('REQUEST'),
  response('RESPONSE'),
  event('EVENT');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid message type: $value'),
    );
  }
}

/// Statuts de réponse.
enum ResponseStatus {
  success('SUCCESS'),
  error('ERROR'),
  unauthorized('UNAUTHORIZED'),
  invalidRequest('INVALID_REQUEST'),
  notFound('NOT_FOUND');

  final String value;
  const ResponseStatus(this.value);

  static ResponseStatus fromString(String value) {
    return ResponseStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid status: $value'),
    );
  }
}

/// Requête envoyée par le client.
class Request {
  Request({
    required this.requestId,
    required this.action,
    required this.token,
    this.payload,
  });

  /// Identifiant unique de la requête (pour corrélation).
  final String requestId;

  /// Action à effectuer.
  final RequestAction action;

  /// Jeton de session (optionnel pour LOGIN).
  final String? token;

  /// Données supplémentaires pour l'action.
  final Map<String, dynamic>? payload;

  /// Crée une Request depuis JSON.
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestId: json['request_id'] as String,
      action: RequestAction.fromString(json['action'] as String),
      token: json['token'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  /// Convertit la Request en JSON.
  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'type': MessageType.request.value,
      'action': action.value,
      'token': token,
      'payload': payload,
    };
  }
}

/// Réponse envoyée par le serveur.
class Response {
  Response({
    required this.requestId,
    required this.status,
    this.data,
    this.error,
  });

  /// Identifiant de la requête correspondante.
  final String requestId;

  /// Statut de la réponse.
  final ResponseStatus status;

  /// Données de retour (si succès).
  final Map<String, dynamic>? data;

  /// Message d'erreur (si échec).
  final String? error;

  /// Crée une Response depuis JSON.
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      requestId: json['request_id'] as String,
      status: ResponseStatus.fromString(json['status'] as String),
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  /// Convertit la Response en JSON.
  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'type': MessageType.response.value,
      'status': status.value,
      'data': data,
      'error': error,
    };
  }

  /// Crée une réponse de succès.
  factory Response.success(String requestId, {Map<String, dynamic>? data}) {
    return Response(
      requestId: requestId,
      status: ResponseStatus.success,
      data: data,
    );
  }

  /// Crée une réponse d'erreur.
  factory Response.error(String requestId, String error) {
    return Response(
      requestId: requestId,
      status: ResponseStatus.error,
      error: error,
    );
  }

  /// Crée une réponse non autorisée.
  factory Response.unauthorized(String requestId) {
    return Response(
      requestId: requestId,
      status: ResponseStatus.unauthorized,
      error: 'Invalid or expired token',
    );
  }
}

/// Événement envoyé par le serveur (notification temps réel).
class Event {
  Event({
    required this.eventId,
    required this.event,
    required this.payload,
  });

  /// Identifiant unique de l'événement.
  final String eventId;

  /// Type d'événement.
  final String event;

  /// Données de l'événement.
  final Map<String, dynamic> payload;

  /// Crée un Event depuis JSON.
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] as String,
      event: json['event'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }

  /// Convertit l'Event en JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': MessageType.event.value,
      'event_id': eventId,
      'event': event,
      'payload': payload,
    };
  }
}
