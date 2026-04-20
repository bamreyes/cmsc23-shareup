enum RequestStatus { pending, accepted, rejected, cancelled, completed }

class RequestModel {
  final String postId;
  final String requesterId;
  final DateTime pickupDatetime;
  final String? message;
  final RequestStatus status;
  final DateTime createdAt;

  RequestModel({
    required this.postId,
    required this.requesterId,
    required this.pickupDatetime,
    this.message,
    required this.status,
    required this.createdAt,
  });
}
