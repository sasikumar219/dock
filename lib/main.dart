import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, isDragging) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(minWidth: 48),
                height: isDragging ? 56 : 48, // Scale when dragging.
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDragging
                      ? Colors.primaries[
                  e.hashCode % Colors.primaries.length]
                      .withOpacity(0.8) // Slight fade effect.
                      : Colors.primaries[e.hashCode % Colors.primaries.length],
                  boxShadow: isDragging
                      ? [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  /// Includes an `isDragging` flag.
  final Widget Function(T, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
 class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Currently dragged item.
  T? _draggingItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items
            .asMap()
            .entries
            .map(
              (entry) => LongPressDraggable<T>(
            data: entry.value,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Transform.scale(
              scale: 1.2,
              child: Material(
                color: Colors.transparent,
                child: widget.builder(entry.value, true),
              ),
            ),
            onDragStarted: () {
              setState(() {
                print("hai");
                _draggingItem = entry.value;
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggingItem = null;
              });
            },
            onDragEnd: (_) {
              setState(() {
                _draggingItem = null;
              });
            },
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: widget.builder(entry.value, false),
            ),
            child: DragTarget<T>(
              onAccept: (receivedItem) {
                setState(() {
                  final oldIndex = _items.indexOf(receivedItem);
                  final newIndex = entry.key;

                  _items.removeAt(oldIndex);
                  _items.insert(newIndex, receivedItem);
                });
              },
              onWillAccept: (receivedItem) => receivedItem != entry.value,
              builder: (context, candidateData, rejectedData) {
                return widget.builder(
                    entry.value, _draggingItem == entry.value);
              },
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
