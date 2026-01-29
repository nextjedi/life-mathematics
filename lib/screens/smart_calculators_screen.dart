import 'package:flutter/material.dart';

class SmartCalculatorsScreen extends StatelessWidget {
  const SmartCalculatorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _CalculatorCard(
              title: 'Compound Interest',
              icon: Icons.trending_up,
              color: Colors.green,
              onTap: () {
                // TODO: Navigate to compound interest calculator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            _CalculatorCard(
              title: 'Loan Calculator',
              icon: Icons.account_balance,
              color: Colors.blue,
              onTap: () {
                // TODO: Navigate to loan calculator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            _CalculatorCard(
              title: 'EMI Calculator',
              icon: Icons.payment,
              color: Colors.orange,
              onTap: () {
                // TODO: Navigate to EMI calculator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            _CalculatorCard(
              title: 'Investment Returns',
              icon: Icons.attach_money,
              color: Colors.purple,
              onTap: () {
                // TODO: Navigate to investment calculator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CalculatorCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
