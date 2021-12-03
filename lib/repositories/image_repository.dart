import 'dart:io' as io show File;

import 'package:flutter/painting.dart' show NetworkImage;

import 'package:firebase_storage/firebase_storage.dart';


const String _kUserImagesReference = "user-images";
const String _kOuvertureImagesReference = "ouverture-images";

const String _kUserImagePrefix = "user_image_";
const String _kOuvertureImagePrefix = "ouverture_image_";

const String _kPreferredImageFormat = "???";
const int _kPreferredImageWidth = 0;


// TODO: Decide on image properties ^^^.
// TODO: Write repository methods for Ouvertures.
class ImageRepository {
  ImageRepository._internal()
    : this._userImagesRef = FirebaseStorage.instance.ref(_kUserImagesReference);
      //this._ouvertureImagesRef = FirebaseStorage.instance.ref(_kOuvertureImagesReference);

  static final ImageRepository _instance = ImageRepository._internal();
  factory ImageRepository() => _instance;

  final Reference _userImagesRef;
  //final Reference _ouvertureImagesRef;


  String _convertImageToPng() => throw UnimplementedError();

  String _generateUserImageName(String userId) {
    return "$_kUserImagePrefix$userId.$_kPreferredImageFormat";
  }

  String _generateOuvertureImageName() => throw UnimplementedError();

  Future<void> deleteImageWith({String? userId, String? ouvertureId}) {
    if (userId != null) {
      return _userImagesRef
          .child(_generateUserImageName(userId))
          .delete();
    } else {
      throw UnimplementedError();
      /*return _ouvertureImagesRef
          .child(_generateOuvertureImageName(ouvertureId))
          .delete();*/
    }
  }

  Future<void> updateImageWith({required String userId, String? ouvertureId}) {
    throw UnimplementedError();
  }

  Future<void> uploadImageWith({
    required String userId,
    String? ouvertureId,
    required io.File image,
  })  {
    //image = _convertImageToPng(image: image);

    if (ouvertureId == null) {
      return _userImagesRef
          .child(_generateUserImageName(userId))
          .putFile(image);
    } else {
      throw UnimplementedError();
    }
  }
}