import 'package:equatable/equatable.dart';


/// Core keys to use for [Codec]s of classes in the project.
const String kKeyCodecSeparator = ",";
const String kKeyCodecNullValue = "";


/// Root class for core models used in Spotlit project.
/// Core classes should include an _[id]_ unique to the instance.
/// To serialize and revive the class from a _document_, appropriate 
/// [Codec]s should be written per child class.
abstract class SpotlitModel extends Equatable {
  const SpotlitModel(this.id);

  final String id;


  /// Used for storing the fields of the inheriting classes
  /// that are not present in the root class. It is then passed to the [props]
  /// getter of the [Equatable] super class.
  List<Object?> get modelProps;

  @override List<Object?> get props => <Object?>[ this.id, ...modelProps ];


  SpotlitModel copyWith({String? id});
  
  /// Creates a map out of fields of the class to serialize the said class
  /// into appropriate format for storing in the database.
  Map<String, String> toDocument();
}