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
    required this.onSendMessage,
    super.key,
  });

  final DashboardTicket ticket;
  final AuthUser currentUser;
  final ValueChanged<List<DashboardTicketMessage>> onMessagesChanged;
  final Future<void> Function(String body, String? parentMessageId)
      onSendMessage;

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
  bool _isSending = false;

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

  Future<void> _submitMessage() async {
    if (_isSending) {
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    final parentMessageId = _replyTargetId;
    final tempId = 'tmp-${DateTime.now().microsecondsSinceEpoch}';

    final newMessage = DashboardTicketMessage(
      id: tempId,
      authorName: widget.currentUser.displayName,
      authorRoleLabel: widget.currentUser.role.label,
      body: text,
      timeLabel: 'Ahora',
      parentMessageId: parentMessageId,
      isCurrentUser: true,
    );

    setState(() {
      _messages = <DashboardTicketMessage>[
        ..._messages,
        newMessage,
      ];
      _messageController.clear();
      _replyTargetId = null;
      _isSending = true;
    });

    widget.onMessagesChanged(
        List<DashboardTicketMessage>.unmodifiable(_messages));

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

    try {
      await widget.onSendMessage(text, parentMessageId);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages = _messages
            .where((message) => message.id != tempId)
            .toList(growable: false);
      });

      widget.onMessagesChanged(
        List<DashboardTicketMessage>.unmodifiable(_messages),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  List<DashboardTicketMessage> _childrenOf(String? parentMessageId) {
    return _messages
        .where((message) => message.parentMessageId == parentMessageId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainerLow,
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
                  isSending: _isSending,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 54,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
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
                      ticket.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ticket.status} • ${ticket.reporter}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ticket.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$messageCount mensajes en esta conversacion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isCurrentUser
        ? colorScheme.primary
        : (isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerLowest);
    final borderColor =
        isCurrentUser ? colorScheme.primary : colorScheme.outlineVariant;
    final textColor =
        isCurrentUser ? colorScheme.onPrimary : colorScheme.onSurface;
    final metaColor = isCurrentUser
        ? colorScheme.onPrimary.withOpacity(0.78)
        : colorScheme.onSurfaceVariant;

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
                      ? colorScheme.onPrimary.withOpacity(0.22)
                      : colorScheme.surfaceContainer,
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
                      ? colorScheme.onPrimary.withOpacity(0.16)
                      : colorScheme.surfaceContainerHigh,
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
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usa el cuadro inferior para iniciar la conversacion del ticket.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    required this.isSending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final DashboardTicketMessage? replyTarget;
  final VoidCallback onCancelReply;
  final Future<void> Function() onSubmit;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
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
                color: colorScheme.primaryContainer.withOpacity(0.48),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Respondiendo a ${replyTarget!.authorName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCancelReply,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerLow,
                      foregroundColor: colorScheme.primary,
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
                onPressed: isSending ? null : onSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isSending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// endregion
