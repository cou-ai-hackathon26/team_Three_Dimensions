import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/services/saved_conversation_service.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/widgets/app_bar_shell.dart';
import '../../core/widgets/confirm_sheet.dart';

class SavedConversationsScreen extends ConsumerStatefulWidget {
  const SavedConversationsScreen({super.key});

  @override
  ConsumerState<SavedConversationsScreen> createState() =>
      _SavedConversationsScreenState();
}

class _SavedConversationsScreenState
    extends ConsumerState<SavedConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SavedConversation> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final list = await SavedConversationService.getConversations();
    if (mounted) {
      setState(() {
        _conversations = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConversation(SavedConversation item, bool isBn) async {
    final confirmed = await ConfirmSheet.show(
      context,
      title: isBn ? 'কথোপকথন মুছে ফেলবেন?' : 'Delete conversation?',
      description: isBn
          ? 'এই কথোপকথনটি আপনার ডিভাইস থেকে স্থায়ীভাবে মুছে ফেলা হবে।'
          : 'This conversation will be permanently deleted from this device.',
      confirmLabel: isBn ? 'মুছে ফেলুন' : 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await SavedConversationService.deleteConversation(item.id);
      setState(() {
        _conversations.removeWhere((c) => c.id == item.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn ? 'কথোপকথন মুছে ফেলা হয়েছে' : 'Conversation deleted',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openConversation(SavedConversation item) {
    ref.read(conversationProvider.notifier).loadSavedConversation(
          caseId: item.id,
          messages: item.messages,
          facts: item.facts,
          checklist: item.checklist,
        );
    context.go('/');
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final settings = ref.watch(settingsProvider);
    final isBn = settings.appLanguage == 'bn';

    final filtered = _conversations.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.snippet.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBarShell(
        title: isBn ? 'সংরক্ষিত কথোপকথন' : 'Saved Conversations',
        showBack: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      isBn ? 'কথোপকথন খুঁজুন...' : 'Search conversations...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: ext.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ext.outlineVariant),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            // Content List or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.forum_outlined,
                                    size: 52, color: ext.outlineVariant),
                                const SizedBox(height: 14),
                                Text(
                                  isBn
                                      ? 'কোনো সংরক্ষিত আলাপ পাওয়া যায়নি'
                                      : 'No saved conversations found',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: ext.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isBn
                                      ? 'নতুন আইনি অনুসন্ধান শুরু করুন, আপনার কথোপকথন স্বয়ংক্রিয়ভাবে সংরক্ষিত হবে।'
                                      : 'Start a legal inquiry, and your conversation will be securely saved here.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ext.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(conversationProvider.notifier)
                                        .startNewConversation();
                                    context.go('/');
                                  },
                                  icon: const Icon(Icons.add_comment_rounded,
                                      size: 18),
                                  label: Text(
                                    isBn
                                        ? 'নতুন আলাপ শুরু করুন'
                                        : 'Start New Conversation',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return Card(
                                elevation: 0,
                                color: ext.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: ext.outlineVariant),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => _openConversation(item),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: ext.onSurface,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              color: ext.onSurfaceVariant,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                  minWidth: 32, minHeight: 32),
                                              tooltip: isBn
                                                  ? 'মুছে ফেলুন'
                                                  : 'Delete',
                                              onPressed: () =>
                                                  _deleteConversation(
                                                      item, isBn),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.snippet,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: ext.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined,
                                                size: 13,
                                                color: ext.onSurfaceVariant),
                                            const SizedBox(width: 5),
                                            Text(
                                              _formatDate(item.updatedAt),
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: ext.onSurfaceVariant,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2.5),
                                              decoration: BoxDecoration(
                                                color: ext.surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: ext.outlineVariant
                                                      .withValues(alpha: 0.5),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                '${item.turnCount} ${isBn ? 'ধাপ' : 'turns'}',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: ext.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
