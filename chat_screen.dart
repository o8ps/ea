import 'package:flutter/material.dart';
import '../services/discord_service.dart';
import '../widgets/ea_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ds = DiscordService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <DiscordMessage>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ds.messageStream.listen((msg) {
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    final msgs = await _ds.fetchMessages();
    if (!mounted) return;
    setState(() { _messages.clear(); _messages.addAll(msgs); _loading = false; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    _msgCtrl.clear();
    await _ds.sendMessage(txt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<bool>(
          stream: _ds.connectionStream,
          builder: (ctx, snap) {
            final connected = snap.data ?? _ds.isConnected;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              color: connected ? const Color(0xFF0F2010) : const Color(0xFF200F0F),
              child: Text(
                connected ? '● Connected' : '● Disconnected',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: connected ? const Color(0xFF72D98A) : const Color(0xFFCC7070),
                  fontFamily: 'monospace',
                ),
              ),
            );
          },
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white24))
              : _messages.isEmpty
                  ? const Center(child: Text('No messages', style: TextStyle(color: Color(0xFF555555), fontSize: 12)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(8),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) => _MessageTile(msg: _messages[i]),
                    ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
          decoration: const BoxDecoration(
            color: Color(0xFF0D0D10),
            border: Border(top: BorderSide(color: Color(0xFF1E1E22))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Message…',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _fetchHistory,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh, size: 18, color: Color(0xFF929292)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatelessWidget {
  final DiscordMessage msg;
  const _MessageTile({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF111114),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E1E22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF2A2A2E),
            backgroundImage: NetworkImage(msg.avatarUrl),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.replyAuthor != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '↩ ${msg.replyAuthor}: ${msg.replyContent ?? ''}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF555555)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Row(
                  children: [
                    Text(msg.authorName, style: const TextStyle(fontSize: 11, color: Color(0xFFB2B2B2), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text(
                      '${msg.timestamp.hour.toString().padLeft(2,'0')}:${msg.timestamp.minute.toString().padLeft(2,'0')}',
                      style: const TextStyle(fontSize: 9, color: Color(0xFF444444)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(msg.content, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
