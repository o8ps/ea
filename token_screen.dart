import 'package:flutter/material.dart';
import '../services/discord_service.dart';
import '../widgets/ea_card.dart';
import '../widgets/ea_button.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final _ds = DiscordService();
  final _tokenCtrl = TextEditingController();
  final _channelCtrl = TextEditingController();
  bool _obscure = true;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _tokenCtrl.text = _ds.token;
    _channelCtrl.text = _ds.channelId;
  }

  void _save() {
    final t = _tokenCtrl.text.trim();
    final c = _channelCtrl.text.trim();
    if (t.isEmpty) { setState(() => _status = 'Enter a token'); return; }
    _ds.token = t;
    _ds.channelId = c;
    _ds.savePrefs();
    _ds.connectWS();
    setState(() => _status = 'Saved — connecting…');
  }

  void _clear() {
    _tokenCtrl.clear();
    _ds.token = '';
    _ds.savePrefs();
    setState(() => _status = 'Cleared');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        EaCard(title: 'Token', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _tokenCtrl,
            obscureText: _obscure,
            style: const TextStyle(fontSize: 12, color: Colors.white, letterSpacing: 1),
            decoration: InputDecoration(
              labelText: 'DISCORD TOKEN',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: const Color(0xFF555555)),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _channelCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: const InputDecoration(labelText: 'DEFAULT CHANNEL ID'),
          ),
          const SizedBox(height: 8),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_status, style: const TextStyle(fontSize: 10, color: Color(0xFF929292), letterSpacing: 1)),
            ),
          EaButton(label: 'Save & Connect', onTap: _save, primary: true),
          const SizedBox(height: 6),
          EaButton(label: 'Clear Token', onTap: _clear, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070)),
        ])),
        EaCard(title: 'Connection', child: StreamBuilder<bool>(
          stream: _ds.connectionStream,
          builder: (ctx, snap) {
            final connected = snap.data ?? _ds.isConnected;
            return Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? const Color(0xFF72D98A) : const Color(0xFFCC7070),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                connected ? 'Connected to Gateway' : 'Disconnected',
                style: const TextStyle(fontSize: 12, color: Color(0xFF929292), letterSpacing: 1),
              ),
            ]);
          },
        )),
        EaCard(title: 'About', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('ea v1.0', style: TextStyle(fontSize: 12, color: Color(0xFF555555), letterSpacing: 2)),
          const SizedBox(height: 4),
          const Text('All settings are saved locally on device.', style: TextStyle(fontSize: 10, color: Color(0xFF444444), letterSpacing: 1)),
        ])),
      ],
    );
  }
}
