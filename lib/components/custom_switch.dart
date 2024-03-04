import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 45.0,
        height: 28.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: value ? Colors.blue.shade900 : Colors.grey,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 2.0,
            bottom: 2.0,
            right: 2.0,
            left: 2.0,
          ),
          child: Container(
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
