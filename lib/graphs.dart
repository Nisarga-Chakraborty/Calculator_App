//import 'dart:ui' as ui;
/*import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

/// Simple expression model
class FunctionExpression {
  String raw; // what user typed: e.g. "y=x", "sin(x)", "1/(x-1)"
  Color color;
  bool visible;
  Expression? parsed;
  String? errorMessage;

  FunctionExpression({
    required this.raw,
    required this.color,
    this.visible = true,
  });
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen>
    with TickerProviderStateMixin {
  final List<FunctionExpression> _functions = [];
  final _controller = TextEditingController();

  // View transform
  Offset _pan = Offset.zero; // in pixels
  double _scale = 40.0; // pixels per unit (initial)
  // internal state for gesture handling
  Offset? _lastFocalPoint;
  double? _startScale;

  // Settings
  bool _showGrid = true;
  bool _showAxisNumbers = true;

  // Colors used for new expressions
  final List<Color> _colorPalette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];
  int _nextColorIndex = 0;

  // Height for the bottom expressions panel (adjustable)
  double _expressionsPanelHeight = 160.0;

  @override
  void initState() {
    super.initState();
    // Add default expressions similar to original
    _addExpressionInternal('y = x');
    _addExpressionInternal('y = x^2');
    _addExpressionInternal(r'y = sin(x)');
  }

  void _addExpressionInternal(String raw) {
    final color = _colorPalette[_nextColorIndex % _colorPalette.length];
    _nextColorIndex++;
    final item = FunctionExpression(raw: raw, color: color);
    _parseExpression(item);
    setState(() {
      _functions.add(item);
    });
  }

  void _parseExpression(FunctionExpression item) {
    final parser = Parser();
    String input = item.raw.trim();

    // Allow users to type 'y=' or just expression
    if (input.startsWith('y=')) {
      input = input.substring(2);
    } else if (input.startsWith('y =')) {
      input = input.substring(3);
    }

    // replace common unicode minus or other quirks if needed
    input = input.replaceAll('−', '-');

    try {
      // math_expressions supports ^ as power, functions like sin, cos
      final expr = parser.parse(input);
      item.parsed = expr;
      item.errorMessage = null;
    } catch (e) {
      item.parsed = null;
      item.errorMessage = (e is Exception) ? e.toString() : 'Parse error';
    }
  }

  // Map screen coordinate to math coordinate
  Offset _screenToWorld(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (local.dx - center.dx - _pan.dx) / _scale;
    final dy = (center.dy + _pan.dy - local.dy) / _scale;
    return Offset(dx, dy);
  }

  // Map world coordinate to screen coordinate
  Offset _worldToScreen(Offset world, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sx = center.dx + _pan.dx + world.dx * _scale;
    final sy = center.dy + _pan.dy - world.dy * _scale;
    return Offset(sx, sy);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _startScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (details.scale != 1.0) {
      // Zoom relative to focal point
      final focal = details.focalPoint;
      final worldFocalBefore = _screenToWorld(focal, size);

      // Update scale
      _scale = (_startScale! * details.scale).clamp(10.0, 200.0);

      final worldFocalAfter = _screenToWorld(focal, size);

      // Adjust pan so the point under finger remains stationary
      final worldDelta = worldFocalAfter - worldFocalBefore;
      _pan = _pan + Offset(worldDelta.dx * _scale, -worldDelta.dy * _scale);
    } else if (details.scale == 1.0 && details.focalPointDelta != Offset.zero) {
      // Panning
      _pan = _pan + details.focalPointDelta;
    }
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
    _startScale = null;
  }

  void _resetView() {
    setState(() {
      _scale = 40.0;
      _pan = Offset.zero;
    });
  }

  void _addExpressionFromInput() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    _addExpressionInternal(raw);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _removeExpression(int index) {
    setState(() {
      _functions.removeAt(index);
    });
  }

  void _toggleVisibility(int index) {
    setState(() {
      _functions[index].visible = !_functions[index].visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Graphing Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 1, 39),
        actions: [
          IconButton(
            icon: Icon(_showGrid ? Icons.grid_on : Icons.grid_off),
            tooltip: _showGrid ? 'Hide Grid' : 'Show Grid',
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset view',
            onPressed: _resetView,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final fullSize = Size(constraints.maxWidth, constraints.maxHeight);
          // Reserve space at bottom for the expressions panel
          final canvasHeight =
              fullSize.height - _expressionsPanelHeight - 24.0; // small margin
          final canvasSize = Size(
            fullSize.width,
            canvasHeight.clamp(100.0, fullSize.height),
          );

          return Stack(
            children: [
              // Graph area (takes remaining space above the bottom panel)
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                height: canvasSize.height,
                child: GestureDetector(
                  onDoubleTap: _resetView,
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        // Zoom with mouse wheel (desktop)
                        final delta = pointerSignal.scrollDelta.dy;
                        final zoomFactor = delta > 0 ? 0.9 : 1.1;
                        final focal = pointerSignal.position;
                        final worldFocalBefore = _screenToWorld(
                          focal,
                          canvasSize,
                        );
                        _scale = (_scale * zoomFactor).clamp(10.0, 200.0);
                        final worldFocalAfter = _screenToWorld(
                          focal,
                          canvasSize,
                        );
                        final worldDelta = worldFocalAfter - worldFocalBefore;
                        _pan =
                            _pan +
                            Offset(
                              worldDelta.dx * _scale,
                              -worldDelta.dy * _scale,
                            );
                        setState(() {});
                      }
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: (details) =>
                          _onScaleUpdate(details, canvasSize),
                      onScaleEnd: _onScaleEnd,
                      child: CustomPaint(
                        size: canvasSize,
                        painter: GraphPainter(
                          functions: _functions,
                          pan: _pan,
                          scale: _scale,
                          showGrid: _showGrid,
                          showNumbers: _showAxisNumbers,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom expressions panel (small, scrollable)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                height: _expressionsPanelHeight,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // Header with a small drag handle and title
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 6,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Expressions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Optional: shrink/expand button (toggles between min and default height)
                            IconButton(
                              icon: const Icon(Icons.expand_less),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  if (_expressionsPanelHeight > 120) {
                                    _expressionsPanelHeight = 80.0;
                                  } else {
                                    _expressionsPanelHeight = 160.0;
                                  }
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Scrollable list (limited height by panel)
                        Expanded(
                          child: Container(
                            // ensures the list area stays compact and scrollable
                            padding: const EdgeInsets.only(right: 4),
                            child: _functions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No expressions. Add one below.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : Scrollbar(
                                    thumbVisibility: true,
                                    child: ListView.builder(
                                      itemCount: _functions.length,
                                      itemBuilder: (context, i) {
                                        final f = _functions[i];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () =>
                                                    _toggleVisibility(i),
                                                child: Icon(
                                                  f.visible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: f.visible
                                                      ? f.color
                                                      : Colors.grey,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      f.raw,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            f.errorMessage ==
                                                                null
                                                            ? Colors.black
                                                            : Colors.red,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    if (f.errorMessage != null)
                                                      Text(
                                                        f.errorMessage!,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: f.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 18,
                                                ),
                                                onPressed: () =>
                                                    _removeExpression(i),
                                                tooltip: 'Remove',
                                                splashRadius: 20,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Input row (compact)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. y = sin(x)',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) => _addExpressionFromInput(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: _addExpressionFromInput,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Icon(Icons.add, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Painter that draws grid, axes and functions
class GraphPainter extends CustomPainter {
  final List<FunctionExpression> functions;
  final Offset pan;
  final double scale;
  final bool showGrid;
  final bool showNumbers;

  GraphPainter({
    required this.functions,
    required this.pan,
    required this.scale,
    this.showGrid = true,
    this.showNumbers = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Apply pan translation
    canvas.save();

    // Background
    final paintBg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, paintBg);

    // grid spacing in world units: choose sensible grid step depending on scale
    final pixelsPerUnit = scale;
    // compute nice step so that major grid lines appear every 1, 2, 5, 10 units depending on zoom
    final stepInPixels = _niceStepPixels(pixelsPerUnit);
    final step = stepInPixels / pixelsPerUnit;

    if (showGrid) {
      _drawGrid(canvas, size, center, step, stepInPixels);
    }

    // Draw axes
    _drawAxes(canvas, size, center);

    // Draw each function
    for (var fn in functions) {
      if (!fn.visible) continue;
      if (fn.parsed == null) continue;

      _drawFunction(canvas, size, center, fn);
    }

    canvas.restore();
  }

  double _niceStepPixels(double pixelsPerUnit) {
    // We want grid lines about every 40-160 pixels; choose factor 1,2,5,10 multiples
    final desired = 80.0;
    final unit = desired / pixelsPerUnit;
    // get power of 10
    final base = math.pow(10, (math.log(unit) / math.ln10).floor()).toDouble();
    for (var m in [1.0, 2.0, 5.0, 10.0]) {
      final candidate = base * m * pixelsPerUnit;
      if (candidate >= 40) return candidate;
    }
    return 40.0;
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    Offset center,
    double stepWorld,
    double stepPixels,
  ) {
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1.0;

    // world bounds
    final leftWorld = -((center.dx + pan.dx) / scale);
    final rightWorld = ((size.width - center.dx - pan.dx) / scale);
    final topWorld = ((center.dy + pan.dy) / scale);
    final bottomWorld = -((size.height - center.dy - pan.dy) / scale);

    // vertical lines
    final firstX = (leftWorld / stepWorld).floor() * stepWorld;
    final lastX = (rightWorld / stepWorld).ceil() * stepWorld;
    for (double x = firstX; x <= lastX; x += stepWorld) {
      final sx = center.dx + pan.dx + x * scale;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paintGrid);
    }

    // horizontal lines
    final firstY = (bottomWorld / stepWorld).floor() * stepWorld;
    final lastY = (topWorld / stepWorld).ceil() * stepWorld;
    for (double y = firstY; y <= lastY; y += stepWorld) {
      final sy = center.dy + pan.dy - y * scale;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paintGrid);
    }

    // thicker major lines (every 5 steps)
    final paintMajor = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1.2;

    final majorMultiple = (stepWorld * (stepPixels >= 120 ? 1 : 5));
    if (majorMultiple > 0) {
      for (
        double x = (firstX / majorMultiple).floor() * majorMultiple;
        x <= lastX;
        x += majorMultiple
      ) {
        final sx = center.dx + pan.dx + x * scale;
        canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paintMajor);
      }
      for (
        double y = (firstY / majorMultiple).floor() * majorMultiple;
        y <= lastY;
        y += majorMultiple
      ) {
        final sy = center.dy + pan.dy - y * scale;
        canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paintMajor);
      }
    }

    // axis numbers
    if (showNumbers) {
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      final labelStyle = const TextStyle(fontSize: 10, color: Colors.black54);
      // vertical axis labels (x)
      for (double x = firstX; x <= lastX; x += stepWorld) {
        final sx = center.dx + pan.dx + x * scale;
        if (sx < -50 || sx > size.width + 50) continue;
        textPainter.text = TextSpan(text: _formatNumber(x), style: labelStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(sx - textPainter.width / 2, center.dy + pan.dy + 4),
        );
      }

      // horizontal axis labels (y)
      for (double y = firstY; y <= lastY; y += stepWorld) {
        final sy = center.dy + pan.dy - y * scale;
        if (sy < -50 || sy > size.height + 50) continue;
        textPainter.text = TextSpan(text: _formatNumber(y), style: labelStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(center.dx + pan.dx + 4, sy - textPainter.height / 2),
        );
      }
    }
  }

  String _formatNumber(double v) {
    if (v.abs() < 1e-6) return '0';
    if (v.abs() >= 1)
      return v.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    return v.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _drawAxes(Canvas canvas, Size size, Offset center) {
    final paintAxis = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Y axis: x = 0
    final x0 = center.dx + pan.dx;
    canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), paintAxis);

    // X axis: y = 0
    final y0 = center.dy + pan.dy;
    canvas.drawLine(Offset(0, y0), Offset(size.width, y0), paintAxis);
  }

  void _drawFunction(
    Canvas canvas,
    Size size,
    Offset center,
    FunctionExpression fn,
  ) {
    final expr = fn.parsed;
    if (expr == null) return;

    final evaluator = expr;
    final cm = ContextModel();

    final path = Path();
    bool moved = false;

    // sample across pixels horizontally with step maybe 1 pixel
    final int pixelStep = 1; // smaller -> smoother but more expensive
    for (int sx = 0; sx <= size.width; sx += pixelStep) {
      // screen to world x
      final wx = (sx - center.dx - pan.dx) / scale;

      // Evaluate
      double? wy;
      try {
        cm.bindVariableName('x', Number(wx));
        final ev = evaluator.evaluate(EvaluationType.REAL, cm);
        if (ev is num) {
          final wyNum = ev.toDouble();
          if (!wyNum.isFinite) {
            wy = null;
          } else {
            wy = wyNum;
          }
        } else {
          wy = null;
        }
      } catch (_) {
        wy = null;
      }

      if (wy == null) {
        moved = false; // discontinuity
        continue;
      }

      final sy = center.dy + pan.dy - wy * scale;
      final point = Offset(sx.toDouble(), sy);

      if (!moved) {
        path.moveTo(point.dx, point.dy);
        moved = true;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final paint = Paint()
      ..color = fn.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return true;
  }
}
*/
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late final WebViewController _webController;
  bool _isDesmosReady = false;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            print("Desmos page loaded");

            // Wait for Desmos to fully initialize
            await Future.delayed(const Duration(milliseconds: 1000));

            // Initialize Desmos calculator with full features enabled
            await _webController.runJavaScript('''
              // Create calculator
              var elt = document.getElementById('calculator');
              window.calculator = Desmos.GraphingCalculator(elt, {
                expressions: true,
                settingsMenu: true,
                zoomButtons: true,
                expressionsCollapsed: false,
                keypad: true,
                graphpaper: true,
                lockViewport: false
              });
              
              // Set nice bounds
              calculator.setMathBounds({
                left: -10,
                right: 10,
                bottom: -10,
                top: 10
              });
              
              // Show grid and axes
              calculator.updateSettings({
                showGrid: true,
                showXAxis: true,
                showYAxis: true,
                xAxisNumbers: true,
                yAxisNumbers: true
              });
              
              // Add some initial example equations
              calculator.setExpression({
                id: 'example1',
                latex: 'y=\\\\sin(x)',
                color: Desmos.Colors.BLUE
              });
              
              calculator.setExpression({
                id: 'example2',
                latex: 'y=x',
                color: Desmos.Colors.RED
              });
              
              console.log("Desmos Calculator initialized with full features!");
            ''');

            // Mark as ready
            setState(() {
              _isDesmosReady = true;
            });
          },
        ),
      )
      ..loadHtmlString('''
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <script src="https://www.desmos.com/api/v1.11/calculator.js?apiKey=YOUR_API_KEY"></script>
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: white;
      }
      #calculator {
        width: 100%;
        height: 100%;
        padding-bottom: 65px;  
        box-sizing: border-box;  
      }
    </style>
  </head>
  <body>
    <div id="calculator"></div>
  </body>
  </html>
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 5, 60),
        title: const Row(
          children: [
            Icon(Icons.show_chart, color: Colors.white),
            SizedBox(width: 4),
            Text(
              "Graphing Calculator",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showInstructions ? Icons.info : Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showInstructions = !_showInstructions;
              });
            },
            tooltip: "Show/Hide Instructions",
          ),
        ],
      ),
      body: Stack(
        children: [
          // Full screen Desmos calculator
          WebViewWidget(controller: _webController),

          // Loading overlay
          if (!_isDesmosReady)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Loading Graphing Calculator...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions overlay
          if (_showInstructions && _isDesmosReady)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "How to Use:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _showInstructions = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem(
                      "➕",
                      "Tap the + button to add new equations",
                    ),
                    _buildInstructionItem(
                      "📝",
                      "Type equations like: y=sin(x), y=x^2, r=2cos(θ)",
                    ),
                    _buildInstructionItem(
                      "⚙️",
                      "Use settings menu for more options",
                    ),
                    _buildInstructionItem("📐", "Pinch to zoom, drag to pan"),
                    _buildInstructionItem(
                      "🎨",
                      "Tap on any equation to edit it",
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Example equations are already loaded!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Floating action button for quick actions
      /*floatingActionButton: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // 👈 align to top
          crossAxisAlignment: CrossAxisAlignment.center, // 👈 align to right
          children: [
            FloatingActionButton.small(
              heroTag: "zoom_in",
              onPressed: () async {
                await _webController.runJavaScript('calculator.zoomIn();');
              },
              child: const Icon(Icons.zoom_in),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: "zoom_out",
              onPressed: () async {
                await _webController.runJavaScript('calculator.zoomOut();');
              },
              child: const Icon(Icons.zoom_out),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: "home",
              onPressed: () async {
                await _webController.runJavaScript('''
            calculator.setMathBounds({
              left: -10,
              right: 10,
              bottom: -10,
              top: 10
            });
          ''');
              },
              child: const Icon(Icons.home),
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      ),
      */
    );
  }

  Widget _buildInstructionItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
