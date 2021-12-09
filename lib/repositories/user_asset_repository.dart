import 'dart:io' as io show File;

import 'package:flutter/painting.dart' show NetworkImage;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

import '../models/spotlit_image.dart';


const String _kUserImagesPath = "user-images";
const String _kUserImageSuffix = "_uimg";

const String _kPreferredImageFormat = "jpg";  // TODO: Experiment with user image format.
const int _kPreferredImageWidth = 200;        // TODO: Experiment with user image width.


class UserAssetRepository {
  UserAssetRepository._internal()
    : this._userImagesRef = FirebaseStorage.instance.ref(_kUserImagesPath);

  static final UserAssetRepository _instance = UserAssetRepository._internal();
  factory UserAssetRepository() => _instance;

  final Reference _userImagesRef;


  /// Restructures the given [image] according to the project definitions of
  /// user photograph standarts.
  /// 
  /// First, resizes the image to [_kPreferredImageWidth] and crops it _square_.
  /// Then encodes the image to convert it to the [_kPreferredImageFormat].
  /// Returns the restructured image as a [io.File] instance.
  io.File _restructureImage(io.File image) {
    img.Image decodedImage = img.decodeImage(image.readAsBytesSync())!;

    decodedImage = img.copyResizeCropSquare(decodedImage, _kPreferredImageWidth);

    // Image formats supported by "image" library can be found here:
    // https://github.com/brendan-duncan/image/blob/2ac55018334635442f32b03015e7086093e83980/lib/src/formats/formats.dart

    // Convert the image to the preferred format.
    late final List<int> encodedBytes;

    switch (_kPreferredImageFormat) {
      case "png":
        encodedBytes = img.encodePng(decodedImage);
        break;
      case "jpg":
        encodedBytes = img.encodeJpg(decodedImage);
        break;
      default:
        throw Exception("Image format $_kPreferredImageFormat is not supported yet.");
    }

    return io.File("temp_profile_img.$_kPreferredImageFormat")
        ..writeAsBytesSync(encodedBytes);
  }

  /// Generates a name for image assets following the template of:
  /// "*[userId]* _ *suffix* . *preferredFormat*"
  /// 
  /// Constants used in this method are defined at the top of the file; namely,
  /// *[_kUserImageSuffix]* and *[_kPreferredImageFormat]*
  String _generateUserImageName(String userId) {
    return "$userId$_kUserImageSuffix.$_kPreferredImageFormat";
  }

  /// Deletes image associated with user with given [userId]. Does not check
  /// if image exists beforehand.
  Future<void> deleteUserImage({required String userId}) {
    return _userImagesRef
        .child(_generateUserImageName(userId))
        .delete();
  }

  /// Gets download link for the user with given _[userId]_. Returns a
  /// [NetworkImage] with retrieved _URL_ and _scale of 1_.
  Future<NetworkImage> downloadUserImage({required String userId}) async {
    final String downloadUrl =
        await _userImagesRef.child(
            _generateUserImageName(userId)
          ).getDownloadURL();
    
    return NetworkImage(downloadUrl, scale: 1);
  }

  /// Updates the image recorded using _ID_ of the user with the new [image].
  /// 
  /// Since there is no direct way to update an file on Cloud Storage,
  /// this method first _deletes_ the image from the storage, and then uploads
  /// it again, using the _ID_ of the user.
  /// 
  /// Returns an [UploadTask] from [uploadUserImage()] being called, hence
  /// should be handled appropriately.
  Future<UploadTask> updateUserImage({
    required String userId,
    required io.File image,
  }) async {
    await deleteUserImage(userId: userId);
    return uploadUserImage(userId: userId, image: image);
  }

  /// Uploads given image to the user images directory in the storage. The
  /// uploaded image is named with following scheme:
  /// *ID_uimg.(extension)*
  /// 
  /// Before uploading, if image is not in preferred format, it gets converted
  /// to the preferred format.
  /// 
  /// Method returns an [UploadTask] for appropriate _BLoC_ to process. To
  /// generate an [SpotlitImage] instance by uploading and recovering the
  /// download link of the image, the [UploadTask] which the method returns
  /// should be used.
  Future<UploadTask> uploadUserImage({
    required String userId,
    required io.File image,
  }) async {
    image = _restructureImage(image);

    return _userImagesRef
        .child(_generateUserImageName(userId))
        .putFile(image);
  }
}