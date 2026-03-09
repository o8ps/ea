import 'package:flutter/material.dart';
import '../services/discord_service.dart';
import '../widgets/ea_card.dart';
import '../widgets/ea_button.dart';

class BeeferScreen extends StatefulWidget {
  const BeeferScreen({super.key});

  @override
  State<BeeferScreen> createState() => _BeeferScreenState();
}

class _BeeferScreenState extends State<BeeferScreen> {
  final _ds = DiscordService();
  final _beeferCtrl = TextEditingController();
  final _pasterCtrl = TextEditingController();
  double _beeferDelay = 1.0;
  double _pasterDelay = 0.5;
  String _beeferStatus = '';
  String _pasterStatus = '';

  void _startBeefer() {
    final lines = _beeferCtrl.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) { setState(() => _beeferStatus = 'Enter messages first'); return; }
    if (_ds.channelId.isEmpty) { setState(() => _beeferStatus = 'Set Channel ID first'); return; }
    _ds.startBeefer(lines, _beeferDelay);
    setState(() => _beeferStatus = 'Running — ${lines.length} lines');
    _ds.beeferTimer = _ds.beeferTimer;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return false;
      if (!_ds.autoBeeferOn) {
        setState(() => _beeferStatus = 'Done');
        return false;
      }
      setState(() => _beeferStatus = 'Sending ${_ds.beeferIdx}/${lines.length}…');
      return true;
    });
  }

  void _stopBeefer() {
    _ds.stopBeefer();
    setState(() => _beeferStatus = 'Stopped at ${_ds.beeferIdx}');
  }

  void _startPaster() {
    final lines = _pasterCtrl.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) { setState(() => _pasterStatus = 'Enter messages first'); return; }
    if (_ds.channelId.isEmpty) { setState(() => _pasterStatus = 'Set Channel ID first'); return; }
    _ds.startPaster(lines, _pasterDelay);
    setState(() => _pasterStatus = 'Looping ${lines.length} messages…');
  }

  void _stopPaster() {
    _ds.stopPaster();
    setState(() => _pasterStatus = 'Stopped');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        EaCard(title: 'AutoBeefer', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('One message per line — sends each once', style: TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _beeferCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'MESSAGES',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delay', style: TextStyle(fontSize: 11, color: Color(0xFF929292), letterSpacing: 1)),
              Text('${_beeferDelay.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 11, color: Colors.white)),
            ],
          ),
          Slider(
            value: _beeferDelay,
            min: 0.5, max: 30, divisions: 59,
            activeColor: Colors.white38,
            inactiveColor: const Color(0xFF2A2A2E),
            onChanged: (v) => setState(() => _beeferDelay = v),
          ),
          if (_beeferStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_beeferStatus, style: const TextStyle(fontSize: 10, color: Color(0xFF929292), letterSpacing: 1)),
            ),
          Row(children: [
            Expanded(child: EaButton(label: 'Start', onTap: _ds.autoBeeferOn ? null : _startBeefer, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Stop', onTap: _ds.autoBeeferOn ? _stopBeefer : null, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'AutoPaster', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sends messages in a loop forever', style: TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 1)),
          const SizedBox(height: 8),
          TextField(
            controller: _pasterCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'MESSAGES',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delay', style: TextStyle(fontSize: 11, color: Color(0xFF929292), letterSpacing: 1)),
              Text('${_pasterDelay.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 11, color: Colors.white)),
            ],
          ),
          Slider(
            value: _pasterDelay,
            min: 0.1, max: 30, divisions: 299,
            activeColor: Colors.white38,
            inactiveColor: const Color(0xFF2A2A2E),
            onChanged: (v) => setState(() => _pasterDelay = v),
          ),
          if (_pasterStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_pasterStatus, style: const TextStyle(fontSize: 10, color: Color(0xFF929292), letterSpacing: 1)),
            ),
          Row(children: [
            Expanded(child: EaButton(label: 'Start', onTap: _ds.autoPasterOn ? null : _startPaster, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Stop', onTap: _ds.autoPasterOn ? _stopPaster : null, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
      ],
    );
  }
}
