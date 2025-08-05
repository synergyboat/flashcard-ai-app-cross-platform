import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String>? onValueChanged;

  const TextInputField({
    super.key,
    this.value = '',
    this.hint = 'Enter your text here',
    this.onValueChanged,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onValueChanged,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignInside,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignInside,
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignInside,
            color: Colors.black.withOpacity(0.0),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignInside,
            color: Colors.redAccent.withOpacity(0.4),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            width: 1.0,
            strokeAlign: BorderSide.strokeAlignInside,
            color: Colors.redAccent.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}