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
      margin: const EdgeInsets.only(top: 0, bottom: 0, left: 50, right: 50),
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
    //  width: MediaQuery.of(context).size.width / 2 - 20,
    //  height: MediaQuery.of(context).size.height / 2 - 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF252222),
      ),
      alignment: Alignment.center,
      child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hızı seslendir:  ',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
