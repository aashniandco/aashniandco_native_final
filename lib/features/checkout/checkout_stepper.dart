import 'package:flutter/material.dart';
class CheckoutStepper extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const CheckoutStepper({Key? key, required this.currentStep}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep("Shipping", "1", 1),
          _buildLine(1),
          _buildStep("Review &\nPay", "2", 2),
          _buildLine(2),
          _buildStep("Complete", "3", 3),
        ],
      ),
    );
  }

  Widget _buildStep(String label, String number, int stepIndex) {
    bool isActive = currentStep >= stepIndex;
    bool isCompleted = currentStep > stepIndex;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isActive ? Colors.green[800]! : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 18, color: Colors.green[800])
                : Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.green[800] : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.black : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _buildLine(int stepIndex) {
    bool isActive = currentStep > stepIndex;
    return Container(
      width: 40,
      height: 1,
      color: isActive ? Colors.green[800] : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 5).copyWith(bottom: 25),
    );
  }
}
