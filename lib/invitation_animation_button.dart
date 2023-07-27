import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class AnimationWidget extends StatefulWidget {
  const AnimationWidget({super.key});

  @override
  State<AnimationWidget> createState() => _AnimationWidgetState();
}

class _AnimationWidgetState extends State<AnimationWidget> {
  Artboard? _artboard;
  SMIInput<bool>? _trigger;

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/fin.riv').then((data) async {
      final file = RiveFile.import(data);

      final artboard = file.mainArtboard;
      var controller =
      StateMachineController.fromArtboard(artboard, 'State Machine 1');

      print(controller);

      if (controller != null) {
        artboard.addController(controller);
        print(controller.inputs.first.name);
        _trigger = controller.findInput('Press');
      }

      setState(() {
        _artboard = artboard;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) return Placeholder();
    return Stack(
      children: [
        Positioned.fill(
          bottom: 32,
          child: Center(
            child: ElevatedButton(
              onPressed: () => setState(() {
                _trigger?.value = true; // what ? //^= this is a trigger apparently
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: Rive(artboard: _artboard!, fit: BoxFit.cover),
            ),
          ),
        )
      ],
    );
  }
}