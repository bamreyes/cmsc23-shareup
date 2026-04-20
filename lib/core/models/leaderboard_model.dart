class LeaderboardModel {
  final String username;
  final String profileImage;
  final int completedExchanges;
  final DateTime updatedAt;

  LeaderboardModel({
    required this.username,
    required this.profileImage,
    required this.completedExchanges,
    required this.updatedAt,
  });
}
