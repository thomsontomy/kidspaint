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

class KidsCanvasPainter extends CustomPainter {
  KidsCanvasPainter(this.lines);

  final Map<PaintProperties, List<Offset>> lines;

  void paint(Canvas canvas, Size size) {
    lines.forEach((paintProperties, points) {
      Paint paint = Paint()
        ..color = paintProperties.color
        ..strokeWidth = paintProperties.thickness
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null)
          canvas.drawLine(points[i], points[i + 1], paint);
      }
    });
  }

  bool shouldRepaint(KidsCanvasPainter other) {
    if (other.lines != lines) {
      return true;
    } else {
      other.lines.forEach((props, list) {
        if (lines[props] != list) {
          return true;
        }
      });
      return false;
    }
  }
}

class KidsPaint extends StatefulWidget {
  KidsPaintState createState() => new KidsPaintState();
}

class KidsPaintState extends State<KidsPaint> {
  PaintProperties _currentPaintProperties = PaintProperties(Colors.red, 5.0);
  Map<PaintProperties, List<Offset>> _lines = Map();

  Widget build(BuildContext context) {
    return new Stack(
      children: [
        GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            RenderBox referenceBox = context.findRenderObject();
            Offset localPosition =
            referenceBox.globalToLocal(details.globalPosition);
            setState(() {
              _lines = Map.from(_lines)
                ..update(
                    _currentPaintProperties, (list) => list..add(localPosition),
                    ifAbsent: () => <Offset>[localPosition]);
            });
          },
          onPanEnd: (DragEndDetails details) => setState(() {
            _lines = Map.from(_lines)
              ..update(_currentPaintProperties, (list) => list..add(null));
          }),
        ),
        CustomPaint(painter: new KidsCanvasPainter(_lines)),
        Column(
          children: <Widget>[
            Expanded(child: Text('')),
            RaisedButton(
              onPressed: () => setState(() => _lines.clear()),
              child: Text('Clean'),
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