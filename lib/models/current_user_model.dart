// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';

import 'package:vapps/enums/user_state.dart';

class CurrentUser {
  late UserState userState;
  late User? user;
  late String message;

  CurrentUser({
    this.userState = UserState.none,
    this.user,
    this.message =
        "An unexpected error occurred, resulting in the return of a default object.",
  });

  @override
  String toString() =>
      'CurrentUser(userState: $userState, user: $user, message: $message)';

  @override
  bool operator ==(covariant CurrentUser other) {
    if (identical(this, other)) return true;

    return other.userState == userState &&
        other.user == user &&
        other.message == message;
  }

  @override
  int get hashCode => userState.hashCode ^ user.hashCode ^ message.hashCode;
}
