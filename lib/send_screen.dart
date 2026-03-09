import 'package:flutter/material.dart';
import '../services/discord_service.dart';
import '../widgets/ea_card.dart';
import '../widgets/ea_button.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _ds = DiscordService();
  final _msgCtrl = TextEditingController();
  final _pingCtrl = TextEditingController();
  double _delay = 0.1;
  String _status = '';

  Future<void> _send() async {
    final raw = _msgCtrl.text.trim();
    if (raw.isEmpty) { setState(() => _status = 'Enter a message'); return; }
    if (_ds.channelId.isEmpty) { setState(() => _status = 'Set Channel ID in Token tab'); return; }
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final ping = _pingCtrl.text.trim();
    setState(() => _status = 'Sending…');
    for (int i = 0; i < lines.length; i++) {
      String msg = '';
      if (ping.isNotEmpty) msg += '<@$ping> ';
      msg += lines[i];
      await _ds.sendMessage(msg);
      if (i < lines.length - 1) await Future.delayed(Duration(milliseconds: (_delay * 1000).toInt()));
    }
    setState(() { _status = 'Sent ${lines.length} message(s)'; _msgCtrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        EaCard(
          title: 'Channel',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TextEditingController(text: _ds.channelId),
                style: const TextStyle(fontSize: 13, color: Colors.white),
                onChanged: (v) { _ds.channelId = v; _ds.savePrefs(); },
                decoration: const InputDecoration(labelText: 'CHANNEL ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pingCtrl,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                decoration: const InputDecoration(labelText: 'PING USER ID (optional)'),
              ),
            ],
          ),
        ),
        EaCard(
          title: 'Message',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _msgCtrl,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'ONE MESSAGE PER LINE',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Delay', style: TextStyle(fontSize: 11, color: Color(0xFF929292), letterSpacing: 1)),
                  Text('${_delay.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 11, color: Colors.white)),
                ],
              ),
              Slider(
                value: _delay,
                min: 0.0, max: 10.0, divisions: 100,
                activeColor: Colors.white38,
                inactiveColor: const Color(0xFF2A2A2E),
                onChanged: (v) => setState(() => _delay = v),
              ),
              if (_status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_status, style: const TextStyle(fontSize: 11, color: Color(0xFF929292), letterSpacing: 1)),
                ),
              EaButton(label: 'Send', onTap: _send, primary: true),
            ],
          ),
        ),
      ],
    );
  }
}
