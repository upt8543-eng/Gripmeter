import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HandgripApp());
}

class HandgripApp extends StatefulWidget {
  const HandgripApp({super.key});

  @override
  State<HandgripApp> createState() => _HandgripAppState();
}

class _HandgripAppState extends State<HandgripApp> {
  bool _isAmoled = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isAmoled
          ? ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              canvasColor: Colors.black,
              cardColor: const Color(0xFF121212),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00E676),
                surface: Color(0xFF161616),
              ),
            )
          : ThemeData.dark(),
      home: MainShell(
        isAmoled: _isAmoled,
        onToggleTheme: (val) => setState(() => _isAmoled = val),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final bool isAmoled;
  final ValueChanged<bool> onToggleTheme;

  const MainShell({super.key, required this.isAmoled, required this.onToggleTheme});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        physics: const BouncingScrollPhysics(),
        children: [
          const RoutinePage(),
          const AnalyticsPage(),
          ProfilePage(isAmoled: widget.isAmoled, onToggleTheme: widget.onToggleTheme),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navBtn(Icons.fitness_center_rounded, "Series", 0),
            _navBtn(Icons.bar_chart_rounded, "Analytics", 1),
            _navBtn(Icons.person_rounded, "Profile", 2),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, String label, int index) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00E676).withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF00E676) : Colors.grey, size: 22),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ----------------- SCREEN 1: ROUTINES -----------------
class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final TextEditingController _nameCtrl = TextEditingController(text: "Handgrip Routine");
  List<Map<String, dynamic>> sets = [
    {"hand": "R", "time": 60},
    {"hand": "L", "time": 60},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Handgrip Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          const Text("Welcome back 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Serie Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sets.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text("Set ${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'L', label: Text('L')),
                              ButtonSegment(value: 'R', label: Text('R')),
                            ],
                            selected: {item["hand"]},
                            onSelectionChanged: (val) => setState(() => item["hand"] = val.first),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (item["time"] > 5) setState(() => item["time"] -= 5);
                            },
                          ),
                          Text("${item["time"]}s", style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => item["time"] += 5),
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Set"),
                        onPressed: () => setState(() => sets.add({"hand": "R", "time": 60})),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Serie saved locally!")),
                          );
                        },
                        child: const Text("Save Serie"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ----------------- SCREEN 2: ANALYTICS -----------------
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Analytics"), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          Row(
            children: [
              _statCard("🔥 Streaks", "7 Days", Colors.orangeAccent),
              const SizedBox(width: 8),
              _statCard("💪 Best R", "180s", const Color(0xFFFF5252)),
              const SizedBox(width: 8),
              _statCard("🤚 Best L", "165s", const Color(0xFF448AFF)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Lifetime Calendar (Cubes)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendDot(const Color(0xFF00E676), "Both (Green)"),
              _legendDot(const Color(0xFFFF5252), "Right (Red)"),
              _legendDot(const Color(0xFF448AFF), "Left (Blue)"),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 200,
              itemBuilder: (context, i) {
                Color c = const Color(0xFF222222);
                if (i % 6 == 0) c = const Color(0xFF00E676);
                else if (i % 4 == 0) c = const Color(0xFFFF5252);
                else if (i % 7 == 0) c = const Color(0xFF448AFF);
                return Container(
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String val, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color c, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

// ----------------- SCREEN 3: PROFILE -----------------
class ProfilePage extends StatelessWidget {
  final bool isAmoled;
  final ValueChanged<bool> onToggleTheme;

  const ProfilePage({super.key, required this.isAmoled, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Profile & Settings"), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF00E676),
              child: Icon(Icons.person, size: 45, color: Colors.black),
            ),
          ),
          const SizedBox(height: 10),
          const Center(child: Text("Offline Athlete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text("Black AMOLED Mode"),
            value: isAmoled,
            onChanged: onToggleTheme,
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text("Export Backup (JSON)"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data exported to device storage!")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text("Import Backup"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data restored successfully!")),
              );
            },
          ),
        ],
      ),
    );
  }
}
