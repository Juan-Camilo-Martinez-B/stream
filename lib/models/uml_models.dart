import 'dart:ui';

import 'visibility_enum.dart';
import 'relation_type_enum.dart';
import 'data_type_enum.dart';

export 'visibility_enum.dart';
export 'relation_type_enum.dart';
export 'data_type_enum.dart';

class UmlAttribute {
  final String id;
  final String name;
  final DataType type;
  final String? customType;
  final UmlVisibility visibility;

  const UmlAttribute({
    required this.id,
    required this.name,
    required this.type,
    this.customType,
    this.visibility = UmlVisibility.private,
  });

  UmlAttribute copyWith({
    String? id,
    String? name,
    DataType? type,
    String? customType,
    UmlVisibility? visibility,
  }) {
    return UmlAttribute(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      customType: customType ?? this.customType,
      visibility: visibility ?? this.visibility,
    );
  }
}

class UmlMethod {
  final String id;
  final String name;
  final DataType returnType;
  final String? customReturnType;
  final String parameters;
  final UmlVisibility visibility;

  const UmlMethod({
    required this.id,
    required this.name,
    required this.returnType,
    this.customReturnType,
    this.parameters = '',
    this.visibility = UmlVisibility.public,
  });

  UmlMethod copyWith({
    String? id,
    String? name,
    DataType? returnType,
    String? customReturnType,
    String? parameters,
    UmlVisibility? visibility,
  }) {
    return UmlMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      returnType: returnType ?? this.returnType,
      customReturnType: customReturnType ?? this.customReturnType,
      parameters: parameters ?? this.parameters,
      visibility: visibility ?? this.visibility,
    );
  }
}



class UmlRelation {
  final String id;
  final String sourceClassId;
  final String targetClassId;
  final RelationType type;

  const UmlRelation({
    required this.id,
    required this.sourceClassId,
    required this.targetClassId,
    required this.type,
  });
}

class UmlClass {
  final String id;
  final String name;
  final Offset position;
  final List<UmlAttribute> attributes;
  final List<UmlMethod> methods;

  const UmlClass({
    required this.id,
    required this.name,
    required this.position,
    this.attributes = const [],
    this.methods = const [],
  });

  UmlClass copyWith({
    String? id,
    String? name,
    Offset? position,
    List<UmlAttribute>? attributes,
    List<UmlMethod>? methods,
  }) {
    return UmlClass(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      attributes: attributes ?? this.attributes,
      methods: methods ?? this.methods,
    );
  }
}

class UmlState {
  final List<UmlClass> classes;
  final List<UmlRelation> relations;

  const UmlState({
    this.classes = const [],
    this.relations = const [],
  });

  UmlState copyWith({
    List<UmlClass>? classes,
    List<UmlRelation>? relations,
  }) {
    return UmlState(
      classes: classes ?? this.classes,
      relations: relations ?? this.relations,
    );
  }

  // Helper method to find a class by ID
  UmlClass? getClassById(String id) {
    try {
      return classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
