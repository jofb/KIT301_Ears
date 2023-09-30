import 'package:flutter/material.dart';

// Yes/No optional follow up dialog for questions
class YesNoDialog extends StatelessWidget {
  const YesNoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.7, //Gets dimension of the screen * 70%
            height: MediaQuery.of(context).size.height *
                0.7, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Select '),
                      TextSpan(
                        text: 'No',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      TextSpan(text: ' or '),
                      TextSpan(
                        text: 'Yes',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'No');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 80.0,
                          horizontal: 100.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'Yes');
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 80.0,
                            horizontal: 100.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.green),
                      child: const Text(
                        'Yes',
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Scale rating optional follow up dialog for questions, rates casualty pain on scale 1-5
class ScaleRatingDialog extends StatefulWidget {
  const ScaleRatingDialog({super.key});

  @override
  State<ScaleRatingDialog> createState() => _ScaleRatingDialogState();
}

class _ScaleRatingDialogState extends State<ScaleRatingDialog> {
  double _sliderValue = 1.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.7, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const CustomSliderThumbCircle(
                            thumbRadius: 30.0,
                            min: 1,
                            max: 10,
                          ),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (newValue) {
                            setState(() {
                              _sliderValue = newValue;
                            });
                          },
                          min: 1,
                          max: 10,
                          divisions: 9, //change to 9 for snappy slider
                          label: null,
                          activeColor: Colors.transparent,
                          inactiveColor: Colors.transparent,
                          thumbColor: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 50.0,
                          horizontal: 60.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _sliderValue.toStringAsFixed(1));
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 50.0,
                            horizontal: 60.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Theme.of(context).indicatorColor),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;
  final String? customLabel; // Custom label for the thumb.

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
    this.customLabel,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white // Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * 1,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor, // Text Color of Value on Thumb
      ),
      text:
      customLabel ?? getValue(value), // Use custom label or default label.
    );

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
    Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * 1, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}

// Number choice optional follow up dialog for questions about number of occupants
class MultipleChoiceDialog extends StatefulWidget {
  const MultipleChoiceDialog({super.key});

  @override
  State<MultipleChoiceDialog> createState() => _MultipleChoiceDialogState();
}

class _MultipleChoiceDialogState extends State<MultipleChoiceDialog> {
  //value to show selected
  int? _value;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.9, //Gets dimension of the screen * 85%
            height: MediaQuery.of(context).size.height *
                0.7, //Gets dimension of the screen * 70%
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //7 buttons with the numbers 1-7
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 1) {
                            _value = null;
                          } else {
                            _value = 1;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 1
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '1',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 1 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 2) {
                            _value = null;
                          } else {
                            _value = 2;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 2
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '2',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 2 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 3) {
                            _value = null;
                          } else {
                            _value = 3;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 3
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 3 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 4) {
                            _value = null;
                          } else {
                            _value = 4;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 4
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '4',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 4 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 5) {
                            _value = null;
                          } else {
                            _value = 5;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 5
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '5',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 5 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 6) {
                            _value = null;
                          } else {
                            _value = 6;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 6
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '6',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 6 ? Colors.white : Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_value == 7) {
                            _value = null;
                          } else {
                            _value = 7;
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                          horizontal: 40.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: _value == 7
                            ? Theme.of(context).indicatorColor
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '7',
                        style: TextStyle(
                            fontSize: 40.0,
                            color: _value == 7 ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 50.0,
                          horizontal: 80.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_value == null) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.pop(context, _value.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 50.0,
                            horizontal: 80.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Theme.of(context).indicatorColor),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
