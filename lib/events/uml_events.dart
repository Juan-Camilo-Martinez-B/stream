import 'dart:ui';
import '../models/uml_models.dart';

abstract class UmlEvent {}

class AddClassEvent extends UmlEvent {
  final String name;
  final Offset position;

  AddClassEvent({required this.name, required this.position});
}

class UpdateClassPositionEvent extends UmlEvent {
  final String classId;
  final Offset newPosition;

  UpdateClassPositionEvent({required this.classId, required this.newPosition});
}

class AddAttributeEvent extends UmlEvent {
  final String classId;
  final UmlAttribute attribute;

  AddAttributeEvent({required this.classId, required this.attribute});
}

class AddMethodEvent extends UmlEvent {
  final String classId;
  final UmlMethod method;

  AddMethodEvent({required this.classId, required this.method});
}

class AddRelationEvent extends UmlEvent {
  final String sourceClassId;
  final String targetClassId;
  final RelationType type;

  AddRelationEvent({
    required this.sourceClassId,
    required this.targetClassId,
    required this.type,
  });
}

class DeleteClassEvent extends UmlEvent {
  final String classId;

  DeleteClassEvent({required this.classId});
}

class EditClassNameEvent extends UmlEvent {
  final String classId;
  final String newName;

  EditClassNameEvent({required this.classId, required this.newName});
}

class EditAttributeEvent extends UmlEvent {
  final String classId;
  final UmlAttribute updatedAttribute;

  EditAttributeEvent({required this.classId, required this.updatedAttribute});
}

class EditMethodEvent extends UmlEvent {
  final String classId;
  final UmlMethod updatedMethod;

  EditMethodEvent({required this.classId, required this.updatedMethod});
}

