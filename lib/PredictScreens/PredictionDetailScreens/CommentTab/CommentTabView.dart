

import 'package:flutter/material.dart';
import 'package:predict365/Models/ThoughtsModel.dart';
import 'package:predict365/Predict_Utils/ColorHandlers/AppColors.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ShimmerLoaderWidget/ShimmerWidget.dart';
import 'package:predict365/ViewModel/ThoughtsVM.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:provider/provider.dart';

class CommentsTabView extends StatefulWidget {
  final String eventId;
  const CommentsTabView({super.key, required this.eventId});

  @override
  State<CommentsTabView> createState() => _CommentsTabViewState();
}

class _CommentsTabViewState extends State<CommentsTabView> {
  final TextEditingController _ctrl      = TextEditingController();
  final ScrollController      _scroll    = ScrollController();
  final FocusNode             _focus     = FocusNode();
  ThoughtModel?               _replyingTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThoughtViewModel>().fetchThoughts(widget.eventId);
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<ThoughtViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send(ThoughtViewModel vm) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final ok = await vm.postThought(text);
    if (ok) {
      _ctrl.clear();
      _focus.unfocus();
      setState(() => _replyingTo = null);
      if (_scroll.hasClients) {
        _scroll.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userVm = context.watch<UserViewModel>();
    final user   = userVm.user;

    return Consumer<ThoughtViewModel>(builder: (context, vm, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
           Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: AppText(
              'Community',

                  fontSize: 18, fontWeight: FontWeight.w700,
            ),
          ),

          // ── Compose box ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current-user avatar
                _Avatar(
                    imageUrl: user?.profileImage,
                    name: user?.name ?? '',
                    radius: 20),
                const SizedBox(width: 12),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color:   Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(color: Theme.of(context).dividerColor),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Reply-to banner
                        if (_replyingTo != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.reply, size: 13,
                                    color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: AppText(
                                    'Replying to ${_replyingTo!.user.displayName}',

                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _replyingTo = null),
                                  child: Icon(Icons.close,
                                      size: 13, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),

                        // Input
                        TextField(
                          controller: _ctrl,
                          focusNode:  _focus,
                          minLines: 3,
                          maxLines: 6,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                          decoration: InputDecoration(

                            hintText: 'Share your thoughts...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                            border:         InputBorder.none,
                            isDense:        true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Send button — gold gradient to match app theme
                        GestureDetector(
                          onTap: vm.isPosting ? null : () => _send(vm),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4952A), Color(0xFFC07B1A)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: vm.isPosting
                                ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                                :  AppText(
                              'Send',

                                color:      Colors.white,
                                fontSize:   15,
                                fontWeight: FontWeight.w700,

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post error
          if (vm.postError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(vm.postError,
                  style: const TextStyle(
                      color: Color(0xFFE05252), fontSize: 12)),
            ),

          const SizedBox(height: 20),

          // ── Comments list ───────────────────────────────────────
          if (vm.isLoading)
            const _CommentsSkeleton()
          else if (vm.status == ThoughtStatus.error)
            _ErrorWidget(
                message: vm.error,
                onRetry: () => vm.fetchThoughts(widget.eventId))
          else if (vm.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'No comments yet. Be the first!',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
              )
            else
              ListView.separated(
                controller: _scroll,
                shrinkWrap: true,
                physics:    const NeverScrollableScrollPhysics(),
                padding:    EdgeInsets.zero,
                itemCount:  vm.thoughts.length + (vm.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => Divider(
                    color: Colors.grey.shade800, height: 1, thickness: 0.5),
                itemBuilder: (context, i) {
                  if (i == vm.thoughts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  final thought = vm.thoughts[i];
                  return _ThoughtThread(
                    thought:       thought,
                    currentUserId: user?.id ?? '',
                    onLike: () => vm.toggleLike(thought.id, user?.id ?? ''),
                    onReply: () {
                      setState(() => _replyingTo = thought);
                      _focus.requestFocus();
                    },
                  );
                },
              ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
// THOUGHT THREAD: top-level comment + indented replies
// ─────────────────────────────────────────────────────────────────
class _ThoughtThread extends StatelessWidget {
  final ThoughtModel thought;
  final String       currentUserId;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const _ThoughtThread({
    required this.thought,
    required this.currentUserId,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main comment row
          _CommentRow(
            thought:       thought,
            currentUserId: currentUserId,
            onLike:        onLike,
            onReply:       onReply,
          ),

          // Indented replies
          if (thought.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 46, top: 10),
              child: Column(
                children: thought.replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CommentRow(
                    thought:       reply,
                    currentUserId: currentUserId,
                    onLike:        () {},    // extend with like-reply API if needed
                    onReply:       onReply,
                    isReply:       true,
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SINGLE COMMENT ROW
//
//  [Avatar]  Name   time ago
//            content text
//            [♡ count]  Reply
// ─────────────────────────────────────────────────────────────────
class _CommentRow extends StatelessWidget {
  final ThoughtModel thought;
  final String       currentUserId;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final bool         isReply;

  const _CommentRow({
    required this.thought,
    required this.currentUserId,
    required this.onLike,
    required this.onReply,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final liked      = thought.isLikedBy(currentUserId);
    final likeColor  = liked ? const Color(0xFFE05252) : Colors.grey.shade500;
    final borderColor = liked ? const Color(0xFFE05252) : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          imageUrl: thought.user.profileImage,
          name:     thought.user.displayName,
          radius:   isReply ? 15 : 20,
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name + time ──────────────────────────────────
              Row(
                children: [
                  Flexible(
                    child: AppText(
                      thought.user.displayName,

                        fontSize:   16,
                        fontWeight: FontWeight.w700,


                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    thought.timeAgo,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ── Content ──────────────────────────────────────
              AppText(
                thought.content.trim(),
                  fontSize: 15,
                  color:    Colors.grey.shade500,

              ),

              const SizedBox(height: 8),

              // ── ♡ pill + Reply ────────────────────────────────
              Row(
                children: [
                  // Like pill
                  GestureDetector(
                    onTap: onLike,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            size:  15,
                            color: likeColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            thought.likes.toString(),
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color:      likeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Reply button (top-level only)
                  if (!isReply)
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w500,
                          color:      Colors.grey.shade400,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Circular avatar with network image + initials fallback ────────
class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String  name;
  final double  radius;

  const _Avatar({this.imageUrl, required this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius:          radius,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: const Color(0xFF2E3249),
      );
    }
    return CircleAvatar(
      radius:          radius,
      backgroundColor: const Color(0xFF2E3249),
      child: Text(
        initial,
        style: TextStyle(
          fontSize:   radius * 0.72,
          fontWeight: FontWeight.w600,
          color:      Colors.white,
        ),
      ),
    );
  }
}

// ── Error widget ──────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 36, color: Colors.grey.shade600),
          const SizedBox(height: 10),
          Text(message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border:       Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Retry',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade300)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shimmer loading placeholder ───────────────────────────────────
class _CommentsSkeleton extends StatelessWidget {
  const _CommentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 40, height: 40, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        ShimmerBox(width: 110, height: 13),
                        const SizedBox(width: 8),
                        ShimmerBox(width: 55, height: 13),
                      ]),
                      const SizedBox(height: 6),
                      ShimmerBox(width: double.infinity, height: 13),
                      const SizedBox(height: 4),
                      ShimmerBox(width: 160, height: 13),
                      const SizedBox(height: 10),
                      ShimmerBox(width: 68, height: 30, radius: 15),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}