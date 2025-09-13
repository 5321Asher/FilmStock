// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:filmstock/main.dart';

class HelpAndFeedback extends StatefulWidget {
  const HelpAndFeedback({super.key});

  @override
  State<HelpAndFeedback> createState() => _HelpAndFeedbackState();
}

class _HelpAndFeedbackState extends State<HelpAndFeedback> {
  MsgType? _selectedType;
  bool isLoading = false;

  final name = GlobalKey<HelpTextFieldState>();
  final email = GlobalKey<HelpTextFieldState>();
  final message = GlobalKey<HelpTextFieldState>();

  String get _selectedTypeLabel {
    switch (_selectedType) {
      case MsgType.feature:
        return "A Feature";
      case MsgType.problem:
        return "A Problem";
      default:
        return "Select message type";
    }
  }

  void _showTypeSelectorDialog(BuildContext context) async {
    final result = await showDialog<MsgType>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'What is this message about?',
          style: TextStyle(
            fontSize: 18,
            color:
                Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        content: MsgTypeSelector(
          selectedType: _selectedType,
          onSelected: (type) {
            Navigator.of(context).pop(type);
          },
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedType = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(title: Text('Help and Feedback')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Screen.height(context) * .02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Screen.width(context) * .1,
              ),
              child: Text(
                'Please fill out this form and we will get back to you shortly',
                style: TextStyle(color: textColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: Screen.height(context) * .1),
            HelpTextField(
              key: name,
              label: 'First and Last Name',
              hint: 'e.g John Doe',
              lines: 1,
            ),
            HelpTextField(
              key: email,
              label: 'Email',
              hint: 'e.g johndoe@email.com',
              lines: 1,
            ),
            SizedBox(
              height: Screen.height(context) * .1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Screen.width(context) * .1,
                  vertical: Screen.height(context) * .02,
                ),
                child: InkWell(
                  onTap: () => _showTypeSelectorDialog(context),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(Screen.width(context) * .03),
                      decoration: BoxDecoration(
                        border: Border.all(color: primary),
                      ),
                      child: InkWell(
                        onTap: () => _showTypeSelectorDialog(context),
                        child: Center(
                          child: Text(
                            _selectedTypeLabel,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            HelpTextField(
              key: message,
              label: 'Message',
              hint: 'Whats this message about?',
              lines: null,
            ),
            Padding(
              padding: EdgeInsets.only(top: Screen.height(context) * .17),
              child: Material(
                color: scaffoldBg,
                child: InkWell(
                  onTap: isLoading ? null : () async {
                    final nameText = name.currentState?.controller.text ?? '';
                    final emailText = email.currentState?.controller.text ?? '';
                    final msgText = message.currentState?.controller.text ?? '';
                    final MsgType? type = _selectedType;

                    if (nameText.isEmpty ||
                        emailText.isEmpty ||
                        msgText.isEmpty ||
                        type == null) {
                      context.showSnackBar('Please Fill Out All Fields');
                      return;
                    }

                    final response = await supabase.from('requests').insert({
                      'user_id': userId,
                      'name': nameText,
                      'email': emailText,
                      'type': type.toString().split('.').last,
                      'message': msgText,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                  
                    if (response == null) {
                      if (mounted) context.showSnackBar('Submitted');
                      name.currentState?.controller.clear();
                      email.currentState?.controller.clear();
                      message.currentState?.controller.clear();
                      setState(() {
                        _selectedType = null;
                      });
                    } else {
                      context.showSnackBar('Error: ${response.error!.message}');
                    }
                  },
                  child: Container(
                    width: Screen.width(context) * .8,
                    height: Screen.height(context) * .07,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primary,
                        width: Screen.width(context) * .01,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: textColor,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Submit',
                              style: TextStyle(color: textColor, fontSize: 24),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MsgType { feature, problem }

class MsgTypeSelector extends StatelessWidget {
  final MsgType? selectedType;
  final ValueChanged<MsgType> onSelected;

  const MsgTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<MsgType>(
          title: Text('A Feature you\'d like added'),
          value: MsgType.feature,
          groupValue: selectedType,
          onChanged: (MsgType? value) {
            if (value != null) onSelected(value);
          },
        ),
        RadioListTile<MsgType>(
          title: Text('A Problem you encountered'),
          value: MsgType.problem,
          groupValue: selectedType,
          onChanged: (MsgType? value) {
            if (value != null) onSelected(value);
          },
        ),
      ],
    );
  }
}

class HelpTextField extends StatefulWidget {
  final String label;
  final String hint;
  final int? lines;

  const HelpTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.lines,
  });
  @override
  State<HelpTextField> createState() => HelpTextFieldState();
}

class HelpTextFieldState extends State<HelpTextField> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: Screen.width(context) * .1,
        vertical: Screen.height(context) * .02,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          ),
          labelText: widget.label,
          hintText: widget.hint,
          border: OutlineInputBorder(),
        ),
        maxLines: widget.lines,
      ),
    );
  }
}
