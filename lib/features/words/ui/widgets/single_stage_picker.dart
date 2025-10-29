import 'package:flutter/material.dart';

class SingleStagePicker extends StatelessWidget {
  const SingleStagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Stufe wählen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(5, (i) {
                final stage = i + 1;
                return SizedBox(
                  width: 72, height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2D2C2E)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF2D2C2E),
                    ),
                    onPressed: () => Navigator.of(context).pop(stage),
                    child: Text('S$stage'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
