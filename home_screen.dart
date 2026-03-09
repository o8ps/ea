import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'send_screen.dart';
import 'tools_screen.dart';
import 'beefer_screen.dart';
import 'token_screen.dart';
import '../services/discord_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _ds = DiscordService();

  final _tabs = const [
    'CHAT', 'SEND', 'TOOLS', 'BEEFER', 'TOKEN',
  ];

  @override
  void initState() {
    super.initState();
    if (_ds.token.isNotEmpty) _ds.connectWS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ea'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: _tabs.length,
              itemBuilder: (ctx, i) => GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: _tab == i ? const Color(0xFF2A2A2E) : const Color(0xFF141416),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _tab == i ? const Color(0xFF555555) : const Color(0xFF2A2A2E),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: _tab == i ? Colors.white : const Color(0xFF666666),
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<bool>(
        stream: _ds.connectionStream,
        builder: (ctx, snap) {
          return IndexedStack(
            index: _tab,
            children: const [
              ChatScreen(),
              SendScreen(),
              ToolsScreen(),
              BeeferScreen(),
              TokenScreen(),
            ],
          );
        },
      ),
    );
  }
}
