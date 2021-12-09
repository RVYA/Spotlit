import 'package:flutter/foundation.dart' show describeEnum;
import 'package:flutter/painting.dart' show NetworkImage;

enum ImageSizes {
  ldpi,
  mdpi,
  hdpi,
  xhdpi,
  xxhdpi,
  xxxhdpi,
}

extension ImageSizeToString on ImageSizes {
  String toKey() => describeEnum(this);
}

const String _kOuvertureImagesReference = "ouverture-images";
const String _kOuvertureImageSuffix = "_oimg";


// TODO: Will not work on Ouverture model and repository until the website is finished.
// Ouverture designer will be website-only, and this solution berates a lot of problems.

class OuvertureAssetRepository {
  String _generateOuvertureImageName() => throw UnimplementedError();

  Future<void> deleteOuvertureImages() => throw UnimplementedError();

  Future<NetworkImage> downloadOuvertureImages() => throw UnimplementedError();

  Future<void> updateOuvertureImages() => throw UnimplementedError();

  Future<void> uploadOuvertureImages() => throw UnimplementedError();
}