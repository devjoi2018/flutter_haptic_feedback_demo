import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BounceBallPage(),
    );
  }
}

class BounceBallPage extends StatefulWidget {
  @override
  _BounceBallPageState createState() => _BounceBallPageState();
}

class _BounceBallPageState extends State<BounceBallPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasBounced = false;
  bool _isBouncing = false; // Estado de la animación

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Función para generar la vibración con duración aleatoria
  void vibrateOnBounce() async {
    bool? canVibrate = await Vibration.hasVibrator();
    if (canVibrate != null && canVibrate) {
      Vibration.vibrate(duration: 5 + Random().nextInt(16)); // Vibración de 5 a 20 ms
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Haptic Feedback Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Animación de la pelota
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                if (_animation.value > 0.9 && !_hasBounced) {
                  vibrateOnBounce();
                  _hasBounced = true;
                } else if (_animation.value <= 0.9) {
                  _hasBounced = false;
                }
                return Transform.translate(
                  offset: Offset(0, _animation.value * 100),
                  child: Ball(),
                );
              },
            ),
            SizedBox(height: 200), // Espacio entre la pelota y el botón
            // Botón para controlar la animación
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_isBouncing) {
                    _controller.stop(); // Detener la animación
                  } else {
                    _controller.forward(from: 0); // Iniciar la animación
                  }
                  _isBouncing = !_isBouncing; // Cambiar el estado de la animación
                });
              },
              child: Text(_isBouncing ? 'Detener rebote' : 'Rebotar pelota'), // Cambiar el texto del botón
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _controller.stop(); // Detener la animación
                  _isBouncing = false; // Cambiar el estado de la animación
                  List<int> pattern = [
                    0, 5, // Primer rebote
                    10, 5, // Segundo rebote, un poco más débil
                    15, 5, // Tercer rebote, aún más débil
                    20, 5, // Cuarto rebote
                    25, 5, // Quinto rebote
                    30, 5, // Sexto rebote
                    35, 5, // Séptimo rebote
                    40, 5, // Octavo rebote
                    45, 5, // Noveno rebote
                    50, 5, // Décimo rebote
                  ];
                  Vibration.vibrate(pattern: pattern); // Vibración personalizada
                });
              },
              child: Text('Multi toque'), // Cambiar el texto del botón
            ),
          ],
        ),
      ),
    );
  }
}

// Clase para la pelota azul
class Ball extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    );
  }
}
