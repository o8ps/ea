import 'package:flutter/material.dart';
import '../services/discord_service.dart';
import '../widgets/ea_card.dart';
import '../widgets/ea_button.dart';
import '../widgets/ea_field.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _ds = DiscordService();

  final _arUserCtrl   = TextEditingController();
  final _arEmojiCtrl  = TextEditingController();
  final _akUserCtrl   = TextEditingController();
  final _akGuildCtrl  = TextEditingController();
  final _statusCtrl   = TextEditingController();
  final _streamCtrl   = TextEditingController();
  final _streamImgCtrl= TextEditingController();
  final _vcGuildCtrl  = TextEditingController();
  final _vcChanCtrl   = TextEditingController();
  final _delCtrl      = TextEditingController();
  final _renameCtrl   = TextEditingController();

  String _arStatus = '';
  String _akStatus = '';
  String _stStatus = '';
  String _streamStatus = '';
  String _vcStatus = '';
  String _delStatus = '';
  String _renameStatus = '';

  @override
  void initState() {
    super.initState();
    _arUserCtrl.text  = _ds.autoReactTarget;
    _arEmojiCtrl.text = _ds.autoReactEmoji;
    _akUserCtrl.text  = _ds.autoKickTarget;
    _akGuildCtrl.text = _ds.autoKickGuild;
  }

  void _startAutoReact() {
    final uid = _arUserCtrl.text.trim();
    final em  = _arEmojiCtrl.text.trim();
    if (uid.isEmpty || em.isEmpty) { setState(() => _arStatus = 'Enter User ID and emoji'); return; }
    _ds.autoReactOn     = true;
    _ds.autoReactTarget = uid;
    _ds.autoReactEmoji  = em;
    _ds.savePrefs();
    if (!_ds.isConnected) _ds.connectWS();
    setState(() => _arStatus = 'Watching for $uid');
  }

  void _stopAutoReact() {
    _ds.autoReactOn     = false;
    _ds.autoReactTarget = '';
    _ds.autoReactEmoji  = '';
    setState(() => _arStatus = 'Stopped');
  }

  void _startAutoKick() {
    final uid = _akUserCtrl.text.trim();
    final gid = _akGuildCtrl.text.trim();
    if (uid.isEmpty || gid.isEmpty) { setState(() => _akStatus = 'Enter User ID and Guild ID'); return; }
    _ds.autoKickOn     = true;
    _ds.autoKickTarget = uid;
    _ds.autoKickGuild  = gid;
    _ds.savePrefs();
    if (!_ds.isConnected) _ds.connectWS();
    setState(() => _akStatus = 'Watching for $uid');
  }

  void _stopAutoKick() {
    _ds.autoKickOn     = false;
    _ds.autoKickTarget = '';
    _ds.autoKickGuild  = '';
    setState(() => _akStatus = 'Stopped');
  }

  void _setStatus() {
    final txt = _statusCtrl.text.trim();
    if (txt.isEmpty) { setState(() => _stStatus = 'Enter status text'); return; }
    if (!_ds.isConnected) { _ds.connectWS(); setState(() => _stStatus = 'Connecting…'); return; }
    _ds.sendPresence({'status':'online','since':0,'activities':[{'name':'Custom Status','type':4,'state':txt,'emoji':null}],'afk':false});
    setState(() => _stStatus = 'Set: $txt');
  }

  void _clearStatus() {
    if (!_ds.isConnected) return;
    _ds.sendPresence({'status':'online','since':0,'activities':[],'afk':false});
    setState(() => _stStatus = 'Cleared');
  }

  void _setStream() {
    final name = _streamCtrl.text.trim();
    final img  = _streamImgCtrl.text.trim();
    if (name.isEmpty) { setState(() => _streamStatus = 'Enter stream title'); return; }
    if (!_ds.isConnected) { _ds.connectWS(); setState(() => _streamStatus = 'Connecting…'); return; }
    final activity = <String, dynamic>{'name':name,'type':1,'url':'https://twitch.tv/discord'};
    if (img.isNotEmpty) activity['assets'] = {'large_image':img,'large_text':name};
    _ds.sendPresence({'status':'online','since':0,'activities':[activity],'afk':false});
    setState(() => _streamStatus = 'Streaming: $name');
  }

  void _clearStream() {
    if (!_ds.isConnected) return;
    _ds.sendPresence({'status':'online','since':0,'activities':[],'afk':false});
    setState(() => _streamStatus = 'Cleared');
  }

  void _joinVC() {
    final gid = _vcGuildCtrl.text.trim();
    final cid = _vcChanCtrl.text.trim();
    if (gid.isEmpty || cid.isEmpty) { setState(() => _vcStatus = 'Enter Guild ID and Channel ID'); return; }
    if (!_ds.isConnected) { setState(() => _vcStatus = 'Not connected — go to Chat first'); return; }
    _ds.sendVoiceState(gid, cid);
    setState(() => _vcStatus = 'Joined: $cid');
  }

  void _leaveVC() {
    final gid = _vcGuildCtrl.text.trim();
    if (gid.isEmpty) { setState(() => _vcStatus = 'Enter Guild ID'); return; }
    if (!_ds.isConnected) return;
    _ds.sendVoiceState(gid, null);
    setState(() => _vcStatus = 'Left VC');
  }

  Future<void> _deleteMsgs() async {
    final n = int.tryParse(_delCtrl.text.trim()) ?? 5;
    setState(() => _delStatus = 'Deleting…');
    final deleted = await _ds.deleteMessages(n.clamp(1, 100));
    setState(() => _delStatus = 'Deleted $deleted messages');
  }

  Future<void> _rename() async {
    final name = _renameCtrl.text.trim();
    if (name.isEmpty) { setState(() => _renameStatus = 'Enter a name'); return; }
    setState(() => _renameStatus = 'Renaming…');
    await _ds.renameChannel(name);
    setState(() { _renameStatus = 'Renamed to: $name'; _renameCtrl.clear(); });
  }

  Widget _statusText(String s) => s.isEmpty ? const SizedBox.shrink() : Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF929292), letterSpacing: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        EaCard(title: 'Auto React', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _arUserCtrl, label: 'TARGET USER ID'),
          EaField(ctrl: _arEmojiCtrl, label: 'EMOJI (unicode or <:name:id>)'),
          _statusText(_arStatus),
          Row(children: [
            Expanded(child: EaButton(label: 'Start', onTap: _startAutoReact, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Stop', onTap: _stopAutoReact, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'Auto Kick', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _akUserCtrl, label: 'TARGET USER ID'),
          EaField(ctrl: _akGuildCtrl, label: 'GUILD ID'),
          _statusText(_akStatus),
          Row(children: [
            Expanded(child: EaButton(label: 'Start', onTap: _startAutoKick, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Stop', onTap: _stopAutoKick, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'Status', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _statusCtrl, label: 'STATUS TEXT'),
          _statusText(_stStatus),
          Row(children: [
            Expanded(child: EaButton(label: 'Set', onTap: _setStatus, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Clear', onTap: _clearStatus, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'Streaming', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _streamCtrl, label: 'STREAM TITLE'),
          EaField(ctrl: _streamImgCtrl, label: 'IMAGE URL (optional)'),
          _statusText(_streamStatus),
          Row(children: [
            Expanded(child: EaButton(label: 'Set', onTap: _setStream, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Clear', onTap: _clearStream, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'Join / Leave VC', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _vcGuildCtrl, label: 'GUILD ID'),
          EaField(ctrl: _vcChanCtrl, label: 'VOICE CHANNEL ID'),
          _statusText(_vcStatus),
          Row(children: [
            Expanded(child: EaButton(label: 'Join', onTap: _joinVC, color: const Color(0xFF0F2010), textColor: const Color(0xFF72D98A))),
            const SizedBox(width: 8),
            Expanded(child: EaButton(label: 'Leave', onTap: _leaveVC, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070))),
          ]),
        ])),
        EaCard(title: 'Delete Messages', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          EaField(ctrl: _delCtrl, label: 'COUNT (max 100)', keyboardType: TextInputType.number),
          _statusText(_delStatus),
          EaButton(label: 'Delete My Messages', onTap: _deleteMsgs, color: const Color(0xFF200F0F), textColor: const Color(0xFFCC7070)),
        ])),
        EaCard(title: 'Rename GC', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _renameCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            onSubmitted: (_) => _rename(),
            decoration: const InputDecoration(labelText: 'NEW NAME'),
          ),
          const SizedBox(height: 8),
          _statusText(_renameStatus),
          EaButton(label: 'Rename', onTap: _rename, primary: true),
        ])),
      ],
    );
  }
}
