import 'dart:convert';

import 'location.dart';
import 'spotlit_image.dart';
import 'spotlit_model.dart';


const String
  kUserDocKeyFullName    = "fullName",
  kUserDocKeyPhotoUri    = "photoUri",
  kUserDocKeyLocation    = "location",
  kUserDocKeyEmail       = "email",
  kUserDocKeyPhoneNumber = "phoneNumber",
  kUserDocKeyCategories  = "categories",
  kUserDocKeyOuvertures  = "ouvertures";

const String kUnknownProperty = "Property is not generated yet.";


/// An user is called the "_Audience_" in the context of Spotlit. However,
/// if an user has at least one Ouverture _presented_, the user becomes an
/// "_On Air_" user.
enum UserType { audience, spotlit, }


/// _Immutable_ class which holds data of an user present.
/// The [id] of a user is also id of the user's document in database. Other
/// than [photo], all fields of the class is written to the mentioned
/// document. The [location], [followedCategories] and [ouvertureIds] are
/// stored in an encoded fashion and must be _revived_ using
/// appropriate [Codec], which differs on the type of the data present.
/// The [photo] however, is stored on a different database, using "*id*_photo"
/// naming scheme. It's _URI_ can be retrieved from database into a
/// [SpotlitImage] intance, and be downloaded from storage.
/// Since the class is _immutable_, it can only be modified using [copyWith()]
/// method.
class User extends SpotlitModel {
  User({
    required String id,
    required this.fullName,
    required this.photo,
    required this.location,
    this.email,
    this.phoneNumber,
    this.followedCategories = const <String>[],
    this.ouvertureIds = const <String>[],
  })
    : assert(
        (email != null) || (phoneNumber != null),
        "At least one of the e-mail or the phone number of the user must be defined.",
      ),
      super(id);

  User.notRecorded({
    required this.fullName,
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
      this.photo = const SpotlitImage(uri: kUnknownProperty),
      super(kUnknownProperty);


  final String fullName;
  final SpotlitImage photo;
  
  final String? email;
  final String? phoneNumber;
  final Location location;

  final List<String> followedCategories;
  final List<String> ouvertureIds;


  bool get isRecorded => (id != kUnknownProperty) &&
                          (photo.uri != kUnknownProperty);

  UserType get type
      => ouvertureIds.isEmpty? UserType.audience : UserType.spotlit;

  @override
  List<Object?> get modelProps => <Object?>[
      fullName, photo, email, phoneNumber, location,
      followedCategories, ouvertureIds,
    ];


  @override
  User copyWith({
    String? id,
    String? fullName,
    SpotlitImage? photo,
    String? email,
    String? phoneNumber,
    Location? location,
    List<String>? followedCategories,
    List<String>? ouvertureIds,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      photo: photo ?? this.photo,
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
      kUserDocKeyFullName: fullName,
      kUserDocKeyPhotoUri: photo.uri,
      kUserDocKeyEmail: email ?? kKeyCodecNullValue,
      kUserDocKeyPhoneNumber: phoneNumber ?? kKeyCodecNullValue,
      kUserDocKeyLocation: LocationCodec().encode(location),
      kUserDocKeyCategories: followedCategories.join(kKeyCodecSeparator),
      kUserDocKeyOuvertures: ouvertureIds.join(kKeyCodecSeparator),
    };
  }
}


class UserDecoder extends Converter<Map<String, String>, User> {
  @override
  User convert(Map<String, String> input, {String? id,}) {
    final String email = input[kUserDocKeyEmail]!;
    final String phoneNumber = input[kUserDocKeyPhoneNumber]!;

    return User(
      id:                 id!,
      fullName:           input[kUserDocKeyFullName]!,
      photo:              SpotlitImage(uri: input[kUserDocKeyPhotoUri]!),
      location:           LocationCodec().decode(input[kUserDocKeyLocation]!),
      email:              (email == kKeyCodecNullValue)? null : email,
      phoneNumber:        (phoneNumber == kKeyCodecNullValue)? null : phoneNumber,
      followedCategories: input[kUserDocKeyCategories]!.split(kKeyCodecSeparator),
      ouvertureIds:       input[kUserDocKeyOuvertures]!.split(kKeyCodecSeparator),
    );
  }
}
