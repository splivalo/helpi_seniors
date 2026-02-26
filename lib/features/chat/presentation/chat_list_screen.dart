import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';

/// Placeholder za chat ekran — lista razgovora.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.chat)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChatPreview(
            emoji: '🛡️',
            name: 'Helpi podrška',
            lastMessage: 'Dobrodošli! Kako vam možemo pomoći?',
            time: '14:30',
            unread: 1,
          ),
          _ChatPreview(
            emoji: '👩‍🎓',
            name: 'Ana M. — Narudžba #1',
            lastMessage: 'Narudžba je potvrđena. Ana dolazi u ponedjeljak.',
            time: 'Jučer',
            unread: 0,
          ),
        ],
      ),
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview({
    required this.emoji,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });

  final String emoji;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ChatRoomScreen(name: name, emoji: emoji),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time, style: theme.textTheme.bodySmall),
                  if (unread > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mock chat soba — prikazuje poruke i input polje.
class _ChatRoomScreen extends StatelessWidget {
  const _ChatRoomScreen({required this.name, required this.emoji});

  final String name;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Poruke
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ChatBubble(
                    text:
                        'Dobrodošli! Ja sam vaš Helpi koordinator. '
                        'Sve dogovore oko narudžbe vodimo ovdje.',
                    isMe: false,
                    time: '14:30',
                  ),
                  _ChatBubble(
                    text: 'Hvala! Imam pitanje oko termina.',
                    isMe: true,
                    time: '14:32',
                  ),
                  _ChatBubble(
                    text: 'Naravno, slobodno pitajte! Tu smo za vas. 😊',
                    isMe: false,
                    time: '14:33',
                  ),
                ],
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppStrings.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {},
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isMe
                      ? Colors.white.withAlpha(180)
                      : theme.colorScheme.onSurface.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
