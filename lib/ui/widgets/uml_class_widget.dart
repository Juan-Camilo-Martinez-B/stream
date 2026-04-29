import 'package:flutter/material.dart';
import '../../models/uml_models.dart';
import '../../events/uml_events.dart';
import '../../streams/uml_stream_manager.dart';

class UmlClassWidget extends StatelessWidget {
  final UmlClass umlClass;

  const UmlClassWidget({Key? key, required this.umlClass}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: umlClass.position.dx,
      top: umlClass.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          streamManager.dispatch(UpdateClassPositionEvent(
            classId: umlClass.id,
            newPosition: umlClass.position + details.delta,
          ));
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C), // Dark surface
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6C63FF), width: 2), // Neon accent
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header (Class Name)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: () => _editClassName(context),
                        child: Text(
                          umlClass.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        streamManager.dispatch(DeleteClassEvent(classId: umlClass.id));
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    )
                  ],
                ),
              ),
              
              // Attributes Section
              if (umlClass.attributes.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: umlClass.attributes.map((attr) {
                      return GestureDetector(
                        onDoubleTap: () => _editAttribute(context, attr),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${visibilityToString(attr.visibility)} ${attr.name}: ${attr.type == DataType.custom ? attr.customType : dataTypeToString(attr.type)}',
                            style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF3A3A4C)),
              ],
              
              // Methods Section
              if (umlClass.methods.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: umlClass.methods.map((method) {
                      return GestureDetector(
                        onDoubleTap: () => _editMethod(context, method),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '${visibilityToString(method.visibility)} ${method.name}(${method.parameters}): ${method.returnType == DataType.custom ? method.customReturnType : dataTypeToString(method.returnType)}',
                            style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              
              // Add Attribute/Method buttons
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF3A3A4C))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _addAttribute(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00FFC4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('+ Attr', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    Container(width: 1, height: 20, color: const Color(0xFF3A3A4C)),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _addMethod(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF007F),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('+ Meth', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addAttribute(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        DataType type = DataType.stringType;
        String customType = '';
        UmlVisibility vis = UmlVisibility.private;
        
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Add Attribute', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UmlVisibility>(
                    value: vis,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: UmlVisibility.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                    onChanged: (v) => setState(() => vis = v!),
                    decoration: const InputDecoration(labelText: 'UmlVisibility', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) => name = v,
                  ),
                  DropdownButtonFormField<DataType>(
                    value: type,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: DataType.values.map((t) => DropdownMenuItem(value: t, child: Text(dataTypeToString(t)))).toList(),
                    onChanged: (v) => setState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Type Preset', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  if (type == DataType.custom)
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Custom Type', labelStyle: TextStyle(color: Colors.grey)),
                      onChanged: (v) => customType = v,
                    ),
                ],
              );
            }
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && (type != DataType.custom || customType.isNotEmpty)) {
                  streamManager.dispatch(AddAttributeEvent(
                    classId: umlClass.id,
                    attribute: UmlAttribute(id: '', name: name, type: type, customType: customType, visibility: vis),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addMethod(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        DataType type = DataType.voidType;
        String customType = '';
        UmlVisibility vis = UmlVisibility.public;

        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Add Method', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UmlVisibility>(
                    value: vis,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: UmlVisibility.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                    onChanged: (v) => setState(() => vis = v!),
                    decoration: const InputDecoration(labelText: 'UmlVisibility', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) => name = v,
                  ),
                  DropdownButtonFormField<DataType>(
                    value: type,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: DataType.values.map((t) => DropdownMenuItem(value: t, child: Text(dataTypeToString(t)))).toList(),
                    onChanged: (v) => setState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Return Type Preset', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  if (type == DataType.custom)
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Custom Return Type', labelStyle: TextStyle(color: Colors.grey)),
                      onChanged: (v) => customType = v,
                    ),
                ],
              );
            }
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && (type != DataType.custom || customType.isNotEmpty)) {
                  streamManager.dispatch(AddMethodEvent(
                    classId: umlClass.id,
                    method: UmlMethod(id: '', name: name, returnType: type, customReturnType: customType, visibility: vis),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editClassName(BuildContext context) {
    String name = umlClass.name;
    String? errorText;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2C),
              title: const Text('Edit Class Name', style: TextStyle(color: Colors.white)),
              content: TextFormField(
                initialValue: name,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name', 
                  labelStyle: const TextStyle(color: Colors.grey),
                  errorText: errorText,
                ),
                onChanged: (v) {
                  setState(() {
                    name = v;
                    errorText = null;
                  });
                },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (name.trim().isEmpty) {
                      setState(() => errorText = 'Name cannot be empty');
                      return;
                    }
                    if (name[0] != name[0].toUpperCase()) {
                      setState(() => errorText = 'Must start with a capital letter');
                      return;
                    }
                    if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(name)) {
                      setState(() => errorText = 'Invalid characters');
                      return;
                    }

                    streamManager.dispatch(EditClassNameEvent(classId: umlClass.id, newName: name));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _editAttribute(BuildContext context, UmlAttribute attr) {
    String name = attr.name;
    DataType type = attr.type;
    String customType = attr.customType ?? '';
    UmlVisibility vis = attr.visibility;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Edit Attribute', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UmlVisibility>(
                    value: vis,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: UmlVisibility.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                    onChanged: (v) => setState(() => vis = v!),
                    decoration: const InputDecoration(labelText: 'UmlVisibility', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  TextFormField(
                    initialValue: name,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) => name = v,
                  ),
                  DropdownButtonFormField<DataType>(
                    value: type,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: DataType.values.map((t) => DropdownMenuItem(value: t, child: Text(dataTypeToString(t)))).toList(),
                    onChanged: (v) => setState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Type Preset', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  if (type == DataType.custom)
                    TextFormField(
                      initialValue: customType,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Custom Type', labelStyle: TextStyle(color: Colors.grey)),
                      onChanged: (v) => customType = v,
                    ),
                ],
              );
            }
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && (type != DataType.custom || customType.isNotEmpty)) {
                  streamManager.dispatch(EditAttributeEvent(
                    classId: umlClass.id,
                    updatedAttribute: attr.copyWith(name: name, type: type, customType: customType, visibility: vis),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editMethod(BuildContext context, UmlMethod method) {
    String name = method.name;
    DataType type = method.returnType;
    String customType = method.customReturnType ?? '';
    String params = method.parameters;
    UmlVisibility vis = method.visibility;
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: const Text('Edit Method', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<UmlVisibility>(
                    value: vis,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: UmlVisibility.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList(),
                    onChanged: (v) => setState(() => vis = v!),
                    decoration: const InputDecoration(labelText: 'UmlVisibility', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  TextFormField(
                    initialValue: name,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) => name = v,
                  ),
                  TextFormField(
                    initialValue: params,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Parameters', labelStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) => params = v,
                  ),
                  DropdownButtonFormField<DataType>(
                    value: type,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: DataType.values.map((t) => DropdownMenuItem(value: t, child: Text(dataTypeToString(t)))).toList(),
                    onChanged: (v) => setState(() => type = v!),
                    decoration: const InputDecoration(labelText: 'Return Type Preset', labelStyle: TextStyle(color: Colors.grey)),
                  ),
                  if (type == DataType.custom)
                    TextFormField(
                      initialValue: customType,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Custom Return Type', labelStyle: TextStyle(color: Colors.grey)),
                      onChanged: (v) => customType = v,
                    ),
                ],
              );
            }
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && (type != DataType.custom || customType.isNotEmpty)) {
                  streamManager.dispatch(EditMethodEvent(
                    classId: umlClass.id,
                    updatedMethod: method.copyWith(name: name, returnType: type, customReturnType: customType, parameters: params, visibility: vis),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
