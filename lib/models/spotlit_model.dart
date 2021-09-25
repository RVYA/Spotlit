import 'package:equatable/equatable.dart';

abstract class SpotlitModel extends Equatable {
  const SpotlitModel(this.id);

  final String id;


  List<Object?> get modelProps;
  @override List<Object?> get props => <Object?>[ this.id, ...modelProps ];


  SpotlitModel copyWith({String? id});
  
  Map<String, Object> toDocument();
}