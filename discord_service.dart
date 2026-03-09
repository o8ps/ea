import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscordMessage {
  final String id;
  final String authorId;
  final String authorName;
  final String? avatarHash;
  final String content;
  final DateTime timestamp;
  final String? replyAuthor;
  final String? replyContent;

  DiscordMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.avatarHash,
    required this.content,
    required this.timestamp,
    this.replyAuthor,
    this.replyContent,
  });

  factory DiscordMessage.fromJson(Map<String, dynamic> j) {
    final ref = j['referenced_message'];
    return DiscordMessage(
      id: j['id'] ?? '',
      authorId: j['author']?['id'] ?? '',
      authorName: j['author']?['username'] ?? 'Unknown',
      avatarHash: j['author']?['avatar'],
      content: j['content'] ?? '',
      timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(),
      replyAuthor: ref?['author']?['username'],
      replyContent: ref?['content'],
    );
  }

  String get avatarUrl {
    if (avatarHash != null) {
      return 'https://cdn.discordapp.com/avatars/$authorId/$avatarHash.webp?size=64';
    }
    return 'https://cdn.discordapp.com/embed/avatars/${int.parse(authorId.isEmpty ? '0' : authorId) % 5}.png';
  }
}

class DiscordService {
  static final DiscordService _instance = DiscordService._internal();
  factory DiscordService() => _instance;
  DiscordService._internal();

  String token = '';
  String channelId = '';
  String? myUserId;

  WebSocketChannel? _ws;
  Timer? _hbTimer;
  Timer? _reconnectTimer;
  bool _connected = false;

  final _messageController = StreamController<DiscordMessage>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<DiscordMessage> get messageStream => _messageController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _connected;

  bool autoReactOn = false;
  String autoReactTarget = '';
  String autoReactEmoji = '';

  bool autoKickOn = false;
  String autoKickTarget = '';
  String autoKickGuild = '';

  bool autoBeeferOn = false;
  List<String> beeferLines = [];
  int beeferIdx = 0;
  Timer? beeferTimer;

  bool autoPasterOn = false;
  List<String> pasterLines = [];
  int pasterIdx = 0;
  Timer? pasterTimer;

  void connectWS() {
    _disconnectWS();
    if (token.isEmpty) return;
    try {
      _ws = WebSocketChannel.connect(Uri.parse('wss://gateway.discord.gg/?v=10&encoding=json'));
      _ws!.stream.listen(_onMessage, onDone: _onClose, onError: (_) => _onClose());
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _disconnectWS() {
    _hbTimer?.cancel();
    _reconnectTimer?.cancel();
    try { _ws?.sink.close(); } catch (_) {}
    _ws = null;
    _connected = false;
    _connectionController.add(false);
  }

  void _onMessage(dynamic raw) {
    final d = jsonDecode(raw);
    final op = d['op'];
    final t = d['t'];
    final data = d['d'];

    if (op == 10) {
      final interval = data['heartbeat_interval'];
      _ws!.sink.add(jsonEncode({
        'op': 2,
        'd': {
          'token': token,
          'intents': 513,
          'properties': {'\$os': 'android', '\$browser': 'ea', '\$device': 'ea'}
        }
      }));
      _hbTimer = Timer.periodic(Duration(milliseconds: interval), (_) {
        _ws?.sink.add(jsonEncode({'op': 1, 'd': null}));
      });
      _connected = true;
      _connectionController.add(true);
      _statusController.add('Connected');
    }

    if (t == 'READY') {
      myUserId = data['user']?['id'];
    }

    if (t == 'MESSAGE_CREATE') {
      final msg = DiscordMessage.fromJson(data);
      if (data['channel_id'] == channelId) {
        _messageController.add(msg);
      }
      _handleAutoReact(data);
      _handleAutoKick(data);
    }
  }

  void _onClose() {
    _hbTimer?.cancel();
    _connected = false;
    _connectionController.add(false);
    _statusController.add('Disconnected');
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (token.isNotEmpty) {
      _reconnectTimer = Timer(const Duration(seconds: 5), connectWS);
    }
  }

  void sendPresence(Map<String, dynamic> presence) {
    if (_ws == null || !_connected) return;
    _ws!.sink.add(jsonEncode({'op': 3, 'd': presence}));
  }

  void sendVoiceState(String guildId, String? channelId) {
    if (_ws == null || !_connected) return;
    _ws!.sink.add(jsonEncode({'op': 4, 'd': {
      'guild_id': guildId,
      'channel_id': channelId,
      'self_mute': false,
      'self_deaf': true,
    }}));
  }

  Future<List<DiscordMessage>> fetchMessages({int limit = 50}) async {
    if (token.isEmpty || channelId.isEmpty) return [];
    try {
      final r = await http.get(
        Uri.parse('https://discord.com/api/v9/channels/$channelId/messages?limit=$limit'),
        headers: {'Authorization': token},
      );
      final data = jsonDecode(r.body);
      if (data is! List) return [];
      return (data as List).map((m) => DiscordMessage.fromJson(m)).toList().reversed.toList();
    } catch (_) { return []; }
  }

  Future<bool> sendMessage(String content, {String? replyToId}) async {
    if (token.isEmpty || channelId.isEmpty) return false;
    final body = <String, dynamic>{'content': content};
    if (replyToId != null) body['message_reference'] = {'message_id': replyToId};
    try {
      final r = await http.post(
        Uri.parse('https://discord.com/api/v9/channels/$channelId/messages'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return r.statusCode == 200;
    } catch (_) { return false; }
  }

  Future<String?> fetchMyId() async {
    if (token.isEmpty) return null;
    try {
      final r = await http.get(
        Uri.parse('https://discord.com/api/v9/users/@me'),
        headers: {'Authorization': token},
      );
      final d = jsonDecode(r.body);
      myUserId = d['id'];
      return myUserId;
    } catch (_) { return null; }
  }

  Future<int> deleteMessages(int count) async {
    final id = myUserId ?? await fetchMyId();
    if (id == null || channelId.isEmpty) return 0;
    try {
      final r = await http.get(
        Uri.parse('https://discord.com/api/v9/channels/$channelId/messages?limit=100'),
        headers: {'Authorization': token},
      );
      final data = jsonDecode(r.body);
      if (data is! List) return 0;
      final mine = (data as List).where((m) => m['author']?['id'] == id).take(count).toList();
      int deleted = 0;
      for (final m in mine) {
        await http.delete(
          Uri.parse('https://discord.com/api/v9/channels/$channelId/messages/${m['id']}'),
          headers: {'Authorization': token},
        );
        deleted++;
        await Future.delayed(const Duration(milliseconds: 600));
      }
      return deleted;
    } catch (_) { return 0; }
  }

  Future<void> renameChannel(String newName) async {
    if (token.isEmpty || channelId.isEmpty) return;
    await http.patch(
      Uri.parse('https://discord.com/api/v9/channels/$channelId'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );
  }

  String _parseEmoji(String raw) {
    final match = RegExp(r'<a?:(\w+):(\d+)>').firstMatch(raw);
    if (match != null) return Uri.encodeComponent('${match.group(1)}:${match.group(2)}');
    return Uri.encodeComponent(raw.trim());
  }

  Future<void> _handleAutoReact(Map<String, dynamic> data) async {
    if (!autoReactOn || autoReactTarget.isEmpty) return;
    if (data['author']?['id'] != autoReactTarget) return;
    final emoji = _parseEmoji(autoReactEmoji);
    try {
      await http.put(
        Uri.parse('https://discord.com/api/v9/channels/${data['channel_id']}/messages/${data['id']}/reactions/$emoji/@me'),
        headers: {'Authorization': token},
      );
    } catch (_) {}
  }

  Future<void> _handleAutoKick(Map<String, dynamic> data) async {
    if (!autoKickOn || autoKickTarget.isEmpty || autoKickGuild.isEmpty) return;
    if (data['author']?['id'] != autoKickTarget) return;
    try {
      await http.delete(
        Uri.parse('https://discord.com/api/v9/guilds/$autoKickGuild/members/$autoKickTarget'),
        headers: {'Authorization': token},
      );
    } catch (_) {}
  }

  void startBeefer(List<String> lines, double delaySec) {
    beeferLines = lines;
    beeferIdx = 0;
    autoBeeferOn = true;
    beeferTimer?.cancel();
    beeferTimer = Timer.periodic(Duration(milliseconds: (delaySec * 1000).toInt()), (_) async {
      if (beeferIdx >= beeferLines.length) { stopBeefer(); return; }
      await sendMessage(beeferLines[beeferIdx]);
      beeferIdx++;
    });
  }

  void stopBeefer() {
    beeferTimer?.cancel();
    autoBeeferOn = false;
    beeferIdx = 0;
  }

  void startPaster(List<String> lines, double delaySec) {
    pasterLines = lines;
    pasterIdx = 0;
    autoPasterOn = true;
    pasterTimer?.cancel();
    pasterTimer = Timer.periodic(Duration(milliseconds: (delaySec * 1000).toInt()), (_) async {
      await sendMessage(pasterLines[pasterIdx % pasterLines.length]);
      pasterIdx++;
    });
  }

  void stopPaster() {
    pasterTimer?.cancel();
    autoPasterOn = false;
    pasterIdx = 0;
  }

  Future<void> savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('token', token);
    await p.setString('channelId', channelId);
    await p.setString('autoReactTarget', autoReactTarget);
    await p.setString('autoReactEmoji', autoReactEmoji);
    await p.setString('autoKickTarget', autoKickTarget);
    await p.setString('autoKickGuild', autoKickGuild);
  }

  Future<void> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    token = p.getString('token') ?? '';
    channelId = p.getString('channelId') ?? '';
    autoReactTarget = p.getString('autoReactTarget') ?? '';
    autoReactEmoji = p.getString('autoReactEmoji') ?? '';
    autoKickTarget = p.getString('autoKickTarget') ?? '';
    autoKickGuild = p.getString('autoKickGuild') ?? '';
  }

  void dispose() {
    _disconnectWS();
    _messageController.close();
    _statusController.close();
    _connectionController.close();
  }
}
