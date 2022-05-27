import 'package:flutter/material.dart';

class TextToSpeechSettingsForm extends StatelessWidget {
  const TextToSpeechSettingsForm({
    required this.isTTSActive,
    required this.activeSetter,
    Key? key,
  }) : super(key: key);

  final bool isTTSActive;
  final void Function(bool) activeSetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF252222),
      ),
      alignment: Alignment.center,
      height: 30,

      child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hızı seslendir:  ',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isTTSActive,
                onChanged: (bool newIsActive) => activeSetter(newIsActive),
                activeColor: const Color(0xFFE9A246),
              ),
            ],
          ),
    );
  }
}
