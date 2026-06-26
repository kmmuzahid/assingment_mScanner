import 'package:flutter/material.dart';

String formatTimeAMPM(DateTime time) {
  final localTime = time.toLocal();
  final hour = localTime.hour;
  final minute = localTime.minute.toString().padLeft(2, '0');
  final ampm = hour >= 12 ? 'PM' : 'AM';
  final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
  
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final monthStr = months[localTime.month - 1];
  
  return '$monthStr ${localTime.day} ${localTime.year} $formattedHour:$minute $ampm';
}

String formatStringIfDate(String value) {
  final parsedDate = DateTime.tryParse(value);
  if (parsedDate != null && value.contains('T') && value.length >= 10) {
    return formatTimeAMPM(parsedDate);
  }
  return value;
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final int threshold;

  const ExpandableTextWidget({
    super.key,
    required this.text,
    this.threshold = 30,
  });

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLongText =
        widget.text.length > widget.threshold || widget.text.contains('\n');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        if (isLongText)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
              child: Text(
                _isExpanded ? 'less' : 'more',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
