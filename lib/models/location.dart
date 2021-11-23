import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'spotlit_model.dart' hide SpotlitModel;


/// _Immutable_ class which is used to store the location of the present user.
/// Not all countries has [state]s or [district]s, hence this fields are
/// nullable. Using _[LocationCodec]_, this class can be encoded to or
/// be revived from a string.
class Location extends Equatable {
  const Location({
    required this.city,
    required this.country,
    this.district,
    this.state,
  });

  final String country;
  final String city; // City may be named province in some countries, such as Turkey.
  
  final String? district;
  final String? state;


  @override
  List<String?> get props => <String?>[
      country, city, district ?? "", state ?? "",
    ];
}


/// Used for encoding to or decoding a _[Location]_ instance from a [String].
class LocationCodec extends Codec<Location, String> {
  @override
  Converter<String, Location> get decoder => _LocationDecoder();

  @override
  Converter<Location, String> get encoder => _LocationEncoder();
}


class _LocationDecoder extends Converter<String, Location> {
  @override
  Location convert(String input) {
    // 0: City
    // 1: Country
    // 2: Province?
    // 3: State?
    final List<String> splitInput = input.split(kKeyCodecSeparator);

    return Location(
      city: splitInput[0],
      country: splitInput[1],
      district: (splitInput[2] == kKeyCodecNullValue)? null : splitInput[2],
      state: (splitInput[3] == kKeyCodecNullValue)? null : splitInput[3],
    );
  }
}

class _LocationEncoder extends Converter<Location, String> {
  // 0: City
  // 1: Country
  // 2: Province?
  // 3: State?
  @override
  String convert(Location input) {
    return
        input.city + kKeyCodecSeparator + input.country + kKeyCodecSeparator
        + (input.district ?? kKeyCodecNullValue) + kKeyCodecSeparator
        + (input.state ?? kKeyCodecNullValue);
  }
}
