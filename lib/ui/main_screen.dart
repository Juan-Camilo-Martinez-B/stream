import 'package:flutter/material.dart';
import '../models/uml_models.dart';
import '../events/uml_events.dart';
import '../streams/uml_stream_manager.dart';
import 'widgets/uml_class_widget.dart';
import 'widgets/relations_painter.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14), // Deep dark background
      appBar: AppBar(
        title: const Text('UML Stream Builder', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
      ),
      body: StreamBuilder<UmlState>(
        stream: streamManager.stateStream,
        initialData: streamManager.currentState,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!;

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.1,
            maxScale: 4.0,
            child: SizedBox(
              // Give the canvas a large virtual size
              width: 10000,
              height: 10000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Draw Relations (Lines) beneath the classes
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RelationsPainter(state),
                    ),
                  ),

                  // Draw Classes
                  ...state.classes.map((c) => UmlClassWidget(umlClass: c)).toList(),
                  
                  // Empty state guide, centered in the virtual canvas
                  if (state.classes.isEmpty)
                    const Positioned(
                      top: 100,
                      left: 100,
                      child: Text(
                        'Tap + to add a UML Class',
                        style: TextStyle(color: Color(0xFF3A3A4C), fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addRelation',
            onPressed: () => _showAddRelationDialog(context),
            backgroundColor: const Color(0xFF00FFC4),
            icon: const Icon(Icons.share, color: Colors.black),
            label: const Text('Add Relation', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'addClass',
            onPressed: () => _showAddClassDialog(context),
            backgroundColor: const Color(0xFF6C63FF),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Class', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    String className = '';
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2C),
              title: const Text('New Class', style: TextStyle(color: Colors.white)),
              content: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  errorText: errorText,
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6C63FF))),
                ),
                onChanged: (v) {
                  setState(() {
                    className = v;
                    errorText = null;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                  onPressed: () {
                    if (className.trim().isEmpty) {
                      setState(() => errorText = 'Name cannot be empty');
                      return;
                    }
                    if (className[0] != className[0].toUpperCase()) {
                      setState(() => errorText = 'Must start with a capital letter');
                      return;
                    }
                    if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(className)) {
                      setState(() => errorText = 'Invalid characters. Use alphanumeric only.');
                      return;
                    }

                    streamManager.dispatch(AddClassEvent(
                      name: className,
                      // Default starting position
                      position: const Offset(100, 100),
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showAddRelationDialog(BuildContext context) {
    final state = streamManager.currentState;
    if (state.classes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 2 classes to create a relation.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String? sourceId = state.classes.first.id;
    String? targetId = state.classes[1].id;
    RelationType type = RelationType.association;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2C),
              title: const Text('New Relation', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: sourceId,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: state.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => sourceId = v),
                    decoration: const InputDecoration(labelText: 'Source', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  DropdownButtonFormField<String>(
                    value: targetId,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: state.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => targetId = v),
                    decoration: const InputDecoration(labelText: 'Target', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  DropdownButtonFormField<RelationType>(
                    value: type,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: RelationType.values.map((t) {
                      String text = t.name;
                      if (text == 'directedAssociation') text = 'Directed Association';
                      else text = text[0].toUpperCase() + text.substring(1);
                      return DropdownMenuItem(value: t, child: Text(text));
                    }).toList(),
                    onChanged: (v) => setState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC4)),
                  onPressed: () {
                    if (sourceId != null && targetId != null && sourceId != targetId) {
                      streamManager.dispatch(AddRelationEvent(
                        sourceClassId: sourceId!,
                        targetClassId: targetId!,
                        type: type,
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Connect', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
