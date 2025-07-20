import 'package:flutter/material.dart';

class ConfidenceScoreWidget extends StatelessWidget {
  final double confidence;

  const ConfidenceScoreWidget({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color scoreColor = _getColorForConfidence(confidence);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: scoreColor.withOpacity(0.2), // Adjust the opacity as needed
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle,
            color: scoreColor,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForConfidence(double confidence) {
    // Example color representation logic
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
