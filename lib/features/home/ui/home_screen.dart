import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: () {}, // TODO: V-Liste
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2A2A2E),
              child: const Text('V', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        title: const Text('Talvori'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {}, // TODO: Rewards/Leaderboard/Stats
            icon: const Icon(Icons.emoji_events_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Chip(
                  backgroundColor: const Color(0xFF2A2A2E),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.countertops_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('231'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('My Words', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          'to assume',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton.icon(
                            onPressed: () {}, // TODO: TTS
                            icon: const Icon(Icons.volume_up),
                            label: const Text('Aussspr.'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A2A2E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {}, // TODO: Web/Mark Words
                              icon: const Icon(Icons.public),
                              label: const Text('Mark Words'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A2A2E),
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {}, // TODO: Push to phone
                              icon: const Icon(Icons.system_update_alt_outlined),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // TODO: Practice-Auswahl
        label: const Text('practice'),
        icon: const Icon(Icons.school),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1C1C1F),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.dashboard_rounded)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.person_rounded)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
