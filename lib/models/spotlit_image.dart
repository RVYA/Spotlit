import 'package:flutter/painting.dart';

import 'package:equatable/equatable.dart';


class SpotlitImage extends Equatable {
  const SpotlitImage({
    required this.uri,
  });

  final String uri;

  ImageProvider get image => NetworkImage(uri);

  @override
  List<Object?> get props => <Object>[uri];
}