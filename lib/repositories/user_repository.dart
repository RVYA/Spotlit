import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';


class UserIsNotRegisteredException implements Exception {
  const UserIsNotRegisteredException({this.message});

  final String? message;

  @override
  String toString() => message ?? "$this.runtimeType";
}


const String _kUsersCollection = "users";


/// This repository is for accessing the _users_ collection in Firestore. It can
/// also be used to generate an user instance from the data in the database. For
/// which also uses the [ImageRepository].
class UserRepository {
  UserRepository._internal()
    : this._usersRef = FirebaseFirestore.instance.collection(_kUsersCollection);

  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;

  final CollectionReference _usersRef;

  // TODO: Add ability to keep user signed in.

  /// Get data of an user from the database and generate an instance of it.
  /// The parameters [phoneNumber] and [email] are intended to use when
  /// authenticating the user.
  /// Throws [UserIsNotRegisteredException] if an document with relevant
  /// [id] or _data_ could not be found.
  Future<User> getUserWith({
    String? id,
    String? phoneNumber,
    String? email,
  }) async {
    assert(
      (id != null) || (phoneNumber != null) || (email != null),
      "At least one of the parameters should be specified.",
    );

    late final DocumentSnapshot userDoc;

    if (id != null) {
      userDoc = await _usersRef.doc(id).get();
    } else {
      final String queryField =
          (email != null)? kUserDocKeyEmail : kUserDocKeyPhoneNumber;
      
      final Query query = _usersRef.where(queryField,
            isEqualTo: email ?? phoneNumber
          );
      
      userDoc = (await query.get()).docs.first;
    }

    if (!userDoc.exists) throw UserIsNotRegisteredException();

    return UserDecoder()
        .convert(userDoc.data() as Map<String, String>, id: userDoc.id);
  }

  /// Simply deletes the document associated with the users _ID_. No checks are
  /// made to know if user exists beforehand.
  Future<void> deleteUser(String userId) => _usersRef.doc(userId).delete();

  /// Records an user to the database and generates an _ID_ for the instance.
  /// The [user] is instanced with [User.notRecorded()] constructor and it does
  /// not have an _ID_. The _ID_ is the one which is generated by Firestore for
  /// the document. Method copies [user] with the generated _ID_ and returns it.
  /// Note that, when the user instance is generated using [User.notRecorded()]
  /// constructor , it does not have an URI for the photograph of user;
  /// this is solved by BLoC of relevant screen to prevent tight coupling.
  Future<User> recordUser(User user) async {
    assert( // Assert that user id is set to kUnknown property. If not, user is already recorded.
      user.id == kUnknownProperty,
      "This user already has an ID associated with it. If you want to "
        "\"update\" this user, please use \"updateUser\" method.",
    );

    final DocumentReference userDoc = await _usersRef.add(user.toDocument());    
    return user.copyWith(id: userDoc.id);
  }

  /// Updates one field with the key [fieldKey] in the user document
  /// with id [userId] to [value].
  Future<void> updateUser({ //TODO: Review updateUser method.
    required String userId,
    required String fieldKey,
    required String value,
  }) {
    return _usersRef.doc(userId).update(<String, String>{fieldKey: value});
  }
}