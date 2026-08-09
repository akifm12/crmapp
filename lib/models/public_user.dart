class PublicUser {
  final int id;
  final String name;
  final String email;
  final bool subscribedToUpdates;

  PublicUser({
    required this.id,
    required this.name,
    required this.email,
    required this.subscribedToUpdates,
  });

  factory PublicUser.fromJson(Map<String, dynamic> json) => PublicUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        subscribedToUpdates: json['subscribed_to_updates'] as bool? ?? false,
      );
}
