// region Componentes Dashboard: imports del chat por ticket
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../domain/models/dashboard_models.dart';
// endregion

// region Componentes Dashboard: panel de chat por ticket
class TicketChatSheet extends StatefulWidget {
  const TicketChatSheet({
    required this.ticket,
    required this.currentUser,
    required this.onMessagesChanged,
    super.key,
  });

  final DashboardTicket ticket;
  final AuthUser currentUser;
  final ValueChanged<List<DashboardTicketMessage>> onMessagesChanged;

  @override
  State<TicketChatSheet> createState() => _TicketChatSheetState();
}
// endregion

// region Lógica Dashboard: estado del chat por ticket
class _TicketChatSheetState extends State<TicketChatSheet> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late List<DashboardTicketMessage> _messages;
  String? _replyTargetId;

  DashboardTicketMessage? get _replyTarget {
    if (_replyTargetId == null) {
      return null;
    }

    for (final message in _messages) {
      if (message.id == _replyTargetId) {
        return message;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _messages = List<DashboardTicketMessage>.from(widget.ticket.chatMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setReplyTarget(DashboardTicketMessage message) {
    setState(() {
      _replyTargetId = message.id;
    });
    _messageFocusNode.requestFocus();
  }

  void _clearReplyTarget() {
    setState(() {
      _replyTargetId = null;
    });
  }

  void _submitMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final newMessage = DashboardTicketMessage(
      id: '${widget.ticket.code}-${DateTime.now().microsecondsSinceEpoch}',
      authorName: widget.currentUser.name,
      authorRoleLabel: widget.currentUser.role.label,
      body: text,
      timeLabel: 'Ahora',
      parentMessageId: _replyTargetId,
      isCurrentUser: true,
    );

    setState(() {
      _messages = <DashboardTicketMessage>[
        ..._messages,
        newMessage,
      ];
      _messageController.clear();
      _replyTargetId = null;
    });

    widget.onMessagesChanged(List<DashboardTicketMessage>.unmodifiable(_messages));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 180,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  List<DashboardTicketMessage> _childrenOf(String? parentMessageId) {
    return _messages
        .where((message) => message.parentMessageId == parentMessageId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FBFD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: <Widget>[
                _ChatSheetHeader(
                  ticket: widget.ticket,
                  messageCount: _messages.length,
                ),
                Expanded(
                  child: _messages.isEmpty
                      ? _EmptyChatState(ticket: widget.ticket)
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: _childrenOf(null)
                              .map(
                                (message) => _ChatMessageBranch(
                                  message: message,
                                  messages: _messages,
                                  onReplySelected: _setReplyTarget,
                                ),
                              )
                              .toList(),
                        ),
                ),
                _ChatComposer(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  replyTarget: _replyTarget,
                  onCancelReply: _clearReplyTarget,
                  onSubmit: _submitMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: cabecera del chat por ticket
class _ChatSheetHeader extends StatelessWidget {
  const _ChatSheetHeader({
    required this.ticket,
    required this.messageCount,
  });

  final DashboardTicket ticket;
  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFDDE7F0),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 54,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD2DEE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ticket.code,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: ticket.accentColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF173B5E),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$messageCount mensajes en esta conversacion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF687C91),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F6FA),
                  foregroundColor: const Color(0xFF51677F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: listado de mensajes del chat por ticket
class _ChatMessageBranch extends StatelessWidget {
  const _ChatMessageBranch({
    required this.message,
    required this.messages,
    required this.onReplySelected,
    this.depth = 0,
  });

  final DashboardTicketMessage message;
  final List<DashboardTicketMessage> messages;
  final ValueChanged<DashboardTicketMessage> onReplySelected;
  final int depth;

  List<DashboardTicketMessage> get _children {
    return messages
        .where((candidate) => candidate.parentMessageId == message.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final leftPadding = depth * 18.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ChatMessageTile(
            message: message,
            onReplySelected: onReplySelected,
          ),
          if (_children.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            ..._children.map(
              (child) => _ChatMessageBranch(
                message: child,
                messages: messages,
                onReplySelected: onReplySelected,
                depth: depth + 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    required this.onReplySelected,
  });

  final DashboardTicketMessage message;
  final ValueChanged<DashboardTicketMessage> onReplySelected;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.isCurrentUser;
    final bubbleColor =
        isCurrentUser ? const Color(0xFF1F6BFF) : const Color(0xFFFFFFFF);
    final borderColor =
        isCurrentUser ? const Color(0xFF1F6BFF) : const Color(0xFFDDE7F0);
    final textColor =
        isCurrentUser ? Colors.white : const Color(0xFF173B5E);
    final metaColor =
        isCurrentUser ? const Color(0xFFD9E8FF) : const Color(0xFF6E8196);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: isCurrentUser
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x221F6BFF),
                  blurRadius: 16,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? const Color(0x33FFFFFF)
                      : const Color(0xFFEAF2F8),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  message.authorName.substring(0, 1).toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                message.authorName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? const Color(0x24FFFFFF)
                      : const Color(0xFFF3F7FA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  message.authorRoleLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: metaColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                message.timeLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: metaColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => onReplySelected(message),
                icon: Icon(
                  Icons.reply_rounded,
                  size: 16,
                  color: metaColor,
                ),
                label: Text(
                  'Responder',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: metaColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({
    required this.ticket,
  });

  final DashboardTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ticket.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.forum_outlined,
                color: ticket.accentColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Este ticket aun no tiene comentarios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF173B5E),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el cuadro inferior para iniciar la conversacion del ticket.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6A7C92),
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: editor de comentarios del chat por ticket
class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.focusNode,
    required this.replyTarget,
    required this.onCancelReply,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final DashboardTicketMessage? replyTarget;
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDDE7F0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (replyTarget != null) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Respondiendo a ${replyTarget!.authorName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF1B4F85),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCancelReply,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1B4F85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: replyTarget == null
                        ? 'Escribe un comentario para este ticket'
                        : 'Escribe una respuesta',
                  ),
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// endregion
