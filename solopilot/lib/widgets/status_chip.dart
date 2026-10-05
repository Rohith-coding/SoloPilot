import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status; // 'pending', 'paid', or 'overdue'
  
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'overdue':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.warning_amber_rounded;
        break;
      case 'pending':
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
