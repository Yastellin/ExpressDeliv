import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/chat_cubit.dart';

class ChatPage extends StatefulWidget {
  final String livraisonId;
  final String currentUserId;

  const ChatPage({
    super.key,
    required this.livraisonId,
    required this.currentUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatCubit _cubit;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = ChatCubit(
      livraisonId: widget.livraisonId,
      currentUserId: widget.currentUserId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: AppColors.card,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    print('🔵 [ChatPage] État reçu : $state');
                    if (state is ChatLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    } else if (state is ChatSuccess) {
                      final messages = state.messages;
                      if (messages.isEmpty) {
                        return _buildEmptyState();
                      }
                      // Scroll en bas après le rebuild
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                      return ListView.builder(
                        key: ValueKey(state.version), // ✅ Force le rebuild
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['expediteur_id'] == widget.currentUserId;
                          return _buildMessageBubble(msg, isMe);
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.alertCircle, size: 48, color: AppColors.error),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Initialisation...'));
                  },
                ),
              ),
              _buildMessageInput(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final timestamp = DateTime.tryParse(message['envoye_at'] ?? '') ?? DateTime.now();
    final expediteurNom = message['expediteur_nom'] ?? '';
    final expediteurPrenom = message['expediteur_prenom'] ?? '';
    final nomComplet = '$expediteurPrenom $expediteurNom'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  nomComplet.isNotEmpty ? nomComplet[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                ),
                border: Border.all(
                  color: isMe ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['contenu'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.messageCircle, size: 48, color: AppColors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Aucun message',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Soyez le premier à envoyer un message',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Écrivez un message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (text) => _sendMessage(context),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: () => _sendMessage(context),
            icon: Icon(LucideIcons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _cubit.sendMessage(text);
    _controller.clear();
  }
}