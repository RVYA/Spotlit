import 'dart:convert';

import 'location.dart';
import 'spotlit_model.dart';


const String
  _kUserDocKeyFullName    = "fullName",
  _kUserDocKeyPhotoUri    = "photoUri",
  _kUserDocKeyLocation    = "location",
  _kUserDocKeyEmail       = "email",
  _kUserDocKeyPhoneNumber = "phoneNumber",
  _kUserDocKeyCategories  = "categories",
  _kUserDocKeyOuvertures  = "ouvertures";


/// An user is called the "_Audience_" in the context of Spotlit. However,
/// if an user has at least one Ouverture _presented_, the user becomes an
/// "_On Air_" user.
enum UserType { audience, onAir, }


/// _Immutable_ class which holds data of an user present.
/// The [id] of a user is also id of the user's document in database. Other
/// than [photoUri], all fields of the class is written to the mentioned
/// document. The [location], [followedCategories] and [ouvertureIds] are
/// stored in an encoded fashion and must be _revived_ using
/// appropriate [Codec], which differs on the type of the data present.
/// The [photoUri] however, is stored on a different database, and is stored
/// using "*id*_photo" naming scheme.
/// Since the class is _immutable_, it can only be modified using [copyWith()]
/// method.
class User extends SpotlitModel {
  User({
    required String id,
    required this.fullName,
    required this.photoUri,
    required this.location,
    this.email,
    this.phoneNumber,
    this.followedCategories = const <String>[],
    this.ouvertureIds = const <String>[],
  })
    : assert(
        (email != null) && (phoneNumber != null),
        "At least one of the e-mail or the phone number of the user must be defined.",
      ),
      super(id);


  final String fullName;
  final String photoUri;
  
  final String? email;
  final String? phoneNumber;
  final Location location;

  final List<String> followedCategories;
  final List<String> ouvertureIds;


  UserType get type => ouvertureIds.isEmpty? UserType.audience : UserType.onAir;

  @override
  List<Object?> get modelProps => <Object?>[
      fullName, photoUri, email, phoneNumber, location,
      followedCategories, ouvertureIds,
    ];


  @override
  User copyWith({
    String? id,
    String? fullName,
    String? photoUri,
    String? email,
    String? phoneNumber,
    Location? location,
    List<String>? followedCategories,
    List<String>? ouvertureIds,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      photoUri: photoUri ?? this.photoUri,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      followedCategories: followedCategories ?? this.followedCategories,
      ouvertureIds: ouvertureIds ?? this.ouvertureIds,
    );
  }

  @override
  Map<String, String> toDocument() {
    return <String, String>{
      _kUserDocKeyFullName: fullName,
      _kUserDocKeyPhotoUri: photoUri,
      _kUserDocKeyEmail: email ?? kKeyCodecNullValue,
      _kUserDocKeyPhoneNumber: phoneNumber ?? kKeyCodecNullValue,
      _kUserDocKeyLocation: LocationCodec().encode(location),
      _kUserDocKeyCategories: followedCategories.join(kKeyCodecSeparator),
      _kUserDocKeyOuvertures: ouvertureIds.join(kKeyCodecSeparator),
    };
  }
}


/*class _UserDecoder extends Converter<Map<String, String>, User> {
  @override
  User convert(Map<String, String> input, {String? id, String? photoUri}) {
    final String email = input[_kUserDocKeyEmail]!;
    final String phoneNumber = input[_kUserDocKeyPhoneNumber]!;

    return User(
      id: id!,
      fullName: input[_kUserDocKeyFullName]!,
      location: LocationCodec().decode(input[_kUserDocKeyLocation]!),
      email: (email == kKeyCodecNullValue)? null : email,
      phoneNumber: (phoneNumber == kKeyCodecNullValue)? null : phoneNumber,
      photoUri: photoUri!,
      followedCategories: input[_kUserDocKeyCategories]!.split(kKeyCodecSeparator),
      ouvertureIds: input[_kUserDocKeyOuvertures]!.split(kKeyCodecSeparator),
    );
  }

}
*/