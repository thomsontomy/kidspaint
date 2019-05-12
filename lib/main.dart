import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

class PaintProperties {
  final Color color;
  final double thickness;

  PaintProperties(this.color, this.thickness);

  @override
  bool operator ==(other) {
    return other is PaintProperties &&
        color.value == other.color.value &&
        thickness == other.thickness;
  }

  @override
  int get hashCode => hash2(color.hashCode, thickness.hashCode);
}

class PaintLine {
  final PaintProperties paint;
  List<Offset> line = List();

  PaintLine(this.paint);
}

class KidsCanvasPainter extends CustomPainter {
  KidsCanvasPainter(this.lines);

  final DoubleLinkedQueue<PaintLine> lines;

  void paint(Canvas canvas, Size size) {
    lines.forEach((PaintLine line) {
      Paint paint = Paint()
        ..color = line.paint.color
        ..strokeWidth = line.paint.thickness
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < line.line.length - 1; i++) {
        if (line.line[i] != null && line.line[i + 1] != null)
          canvas.drawLine(line.line[i], line.line[i + 1], paint);
      }
    });
  }

  bool shouldRepaint(KidsCanvasPainter other) {
    if (other.lines != lines) {
      return true;
    } else {
      return false;
    }
  }
}

class KidsPaint extends StatefulWidget {
  KidsPaintState createState() => new KidsPaintState();
}

class KidsPaintState extends State<KidsPaint> {
  PaintProperties _currentPaintProperties = PaintProperties(Colors.red, 5.0);
  DoubleLinkedQueue<PaintLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = DoubleLinkedQueue.of([PaintLine(_currentPaintProperties)]);
  }

  void undoLastAction() {
    setState(() {
      _lines = DoubleLinkedQueue.from(_lines..removeLast());
      if (_lines.isEmpty) {
        _lines.add(PaintLine(_currentPaintProperties));
      }
    });
  }

  Widget build(BuildContext context) {
    return new Stack(
      children: [
        GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            RenderBox referenceBox = context.findRenderObject();
            Offset localPosition =
            referenceBox.globalToLocal(details.globalPosition);
            setState(() {
              if (_lines.last.paint != _currentPaintProperties) {
                _lines.add(PaintLine(_currentPaintProperties));
              }
              _lines =
                  DoubleLinkedQueue.from(_lines..last.line.add(localPosition));
            });
          },
          onPanEnd: (DragEndDetails details) => setState(() {
            _lines = DoubleLinkedQueue.from(_lines..last.line.add(null));
          }),
        ),
        CustomPaint(painter: new KidsCanvasPainter(_lines)),
        Column(
          children: <Widget>[
            Expanded(child: Text('')),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () =>
                      setState(() =>
                      _lines
                        ..clear()
                        ..add(PaintLine(_currentPaintProperties))),
                  child: Text('Clean'),
                ),
                RaisedButton(
                  onPressed: undoLastAction,
                  child: Text('Undo'),
                )
              ],
            ),
            buildColorPalette(),
          ],
        )
      ],
    );
  }

  Widget buildColorPalette() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          getColorWidget(Colors.blue),
          getColorWidget(Colors.red),
          getColorWidget(Colors.green),
          getColorWidget(Colors.amber),
          getColorWidget(Colors.black),
          getColorWidget(Colors.brown),
          getColorWidget(Colors.cyan),
        ],
      ),
    );
  }

  Widget getColorWidget(Color color) {
    return InkWell(
      child: Container(
        color: color,
        height: 50,
        width: 50,
      ),
      onTap: () => _currentPaintProperties = PaintProperties(color, 5.0),
    );
  }
}

class KidsPaintApp extends StatelessWidget {
  Widget build(BuildContext context) => new Scaffold(body: new KidsPaint());
}

void main() => runApp(new MaterialApp(home: new KidsPaintApp()));
