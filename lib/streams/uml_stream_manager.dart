import 'dart:async';
import 'package:uuid/uuid.dart';
import '../events/uml_events.dart';
import '../models/uml_models.dart';

class UmlStreamManager {
  // Event stream controller to receive user actions
  final StreamController<UmlEvent> _eventController = StreamController<UmlEvent>.broadcast();
  
  // State stream controller to emit the updated state to the UI
  final StreamController<UmlState> _stateController = StreamController<UmlState>.broadcast();

  UmlState _currentState = const UmlState();
  final Uuid _uuid = const Uuid();

  UmlStreamManager() {
    // Listen to incoming events
    _eventController.stream.listen(_handleEvent);
    
    // Emit initial state
    _stateController.add(_currentState);
    
    // Listener 1: Logger for debugging
    _stateController.stream.listen((state) {
      print('=== STATE UPDATED ===');
      print('Classes: ${state.classes.length}');
      print('Relations: ${state.relations.length}');
      print('=====================');
    });

    // Listener 2: Simple validator (prints warning if a class name is 'Error')
    _stateController.stream.listen((state) {
      if (state.classes.any((c) => c.name.toLowerCase() == 'error')) {
        print('WARNING: A class is named "Error". That might be confusing.');
      }
    });
  }

  StreamSink<UmlEvent> get eventSink => _eventController.sink;
  Stream<UmlState> get stateStream => _stateController.stream;
  UmlState get currentState => _currentState;

  void _handleEvent(UmlEvent event) {
    if (event is AddClassEvent) {
      _currentState = _currentState.copyWith(
        classes: List.from(_currentState.classes)..add(
          UmlClass(
            id: _uuid.v4(),
            name: event.name,
            position: event.position,
          ),
        ),
      );
    } else if (event is UpdateClassPositionEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(position: event.newPosition);
          }
          return c;
        }).toList(),
      );
    } else if (event is AddAttributeEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(
              attributes: List.from(c.attributes)..add(
                event.attribute.copyWith(id: _uuid.v4()), // ensure ID
              ),
            );
          }
          return c;
        }).toList(),
      );
    } else if (event is AddMethodEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(
              methods: List.from(c.methods)..add(
                event.method.copyWith(id: _uuid.v4()), // ensure ID
              ),
            );
          }
          return c;
        }).toList(),
      );
    } else if (event is AddRelationEvent) {
      // Filtrar cualquier relación existente entre estas dos clases (en ambas direcciones)
      final newRelations = _currentState.relations.where((r) {
        final isSamePair = (r.sourceClassId == event.sourceClassId && r.targetClassId == event.targetClassId) ||
                           (r.sourceClassId == event.targetClassId && r.targetClassId == event.sourceClassId);
        return !isSamePair;
      }).toList();

      newRelations.add(
        UmlRelation(
          id: _uuid.v4(),
          sourceClassId: event.sourceClassId,
          targetClassId: event.targetClassId,
          type: event.type,
        ),
      );

      _currentState = _currentState.copyWith(relations: newRelations);
    } else if (event is DeleteClassEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.where((c) => c.id != event.classId).toList(),
        relations: _currentState.relations.where((r) => 
          r.sourceClassId != event.classId && r.targetClassId != event.classId
        ).toList(),
      );
    } else if (event is EditClassNameEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(name: event.newName);
          }
          return c;
        }).toList(),
      );
    } else if (event is EditAttributeEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(
              attributes: c.attributes.map((a) {
                return a.id == event.updatedAttribute.id ? event.updatedAttribute : a;
              }).toList(),
            );
          }
          return c;
        }).toList(),
      );
    } else if (event is EditMethodEvent) {
      _currentState = _currentState.copyWith(
        classes: _currentState.classes.map((c) {
          if (c.id == event.classId) {
            return c.copyWith(
              methods: c.methods.map((m) {
                return m.id == event.updatedMethod.id ? event.updatedMethod : m;
              }).toList(),
            );
          }
          return c;
        }).toList(),
      );
    }

    // Emit the new state to all listeners
    _stateController.add(_currentState);
  }

  void dispatch(UmlEvent event) {
    eventSink.add(event);
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}

// Global instance for simplicity in this demo (could use InheritedWidget instead)
final streamManager = UmlStreamManager();
