class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subscriptionPlan,
  });

  final String id;
  final String name;
  final String email;
  final String subscriptionPlan;

  // Remove demo factory - use real user data from API
  // factory UserModel.demo({String? email}) => UserModel(...);
}
