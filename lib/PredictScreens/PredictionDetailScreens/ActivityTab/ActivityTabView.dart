// lib/PredictScreens/PredictionDetailScreens/ActivityTab/ActivityTabView.dart

import 'package:flutter/material.dart';
import 'package:predict365/Models/ActivityModel.dart';
import 'package:predict365/Reusable_Widgets/AppText_Theme/AppText_Theme.dart';
import 'package:predict365/Reusable_Widgets/ShimmerLoaderWidget/ShimmerWidget.dart';
import 'package:predict365/ViewModel/ActivityVM.dart';
import 'package:provider/provider.dart';

class ActivityTabView extends StatefulWidget {
  final String eventId;
  const ActivityTabView({super.key, required this.eventId});

  @override
  State<ActivityTabView> createState() => _ActivityTabViewState();
}

class _ActivityTabViewState extends State<ActivityTabView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().fetchActivities(widget.eventId);
    });
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<ActivityViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) return const _ActivitySkeleton();

        if (vm.status == ActivityStatus.error) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 36, color: Colors.grey.shade500),
                  const SizedBox(height: 10),
                  AppText(vm.error, fontSize: 13, color: Colors.grey.shade500),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => vm.fetchActivities(widget.eventId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText('Retry', fontSize: 13, color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (vm.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: AppText('No activity yet.', fontSize: 14, color: Colors.grey.shade500),
            ),
          );
        }

        return ListView.separated(
          controller: _scroll,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: vm.activities.length + (vm.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) =>
              Divider(color: Theme.of(context).dividerColor, height: 1, thickness: 0.8),
          itemBuilder: (context, i) {
            if (i == vm.activities.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.grey),
                  ),
                ),
              );
            }
            return _ActivityRow(activity: vm.activities[i]);
          },
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final sideColor = activity.isYes
        ? const Color(0xFF22C55E)
        : const Color(0xFFE05252);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(imageUrl: activity.profileImage, name: activity.username),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    AppText(activity.username,
                        fontSize: 14, fontWeight: FontWeight.w600, ),
                    Text(activity.isBuy ? 'bought' : 'sold',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                    AppText(activity.shares.toString(),
                        fontSize: 14, fontWeight: FontWeight.w600, ),
                    _SideBadge(label: activity.side, color: sideColor),
                    Text('shares of',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              AppText(activity.timeAgo,
                  fontSize: 12, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                AppText(activity.marketName,
                   fontSize: 13, fontWeight: FontWeight.w500, ),
                AppText('at', fontSize: 13, color: Colors.grey.shade500),
                AppText(activity.totalLabel,
                   fontSize: 13, fontWeight: FontWeight.w600, ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _SideBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String  name;
  const _Avatar({this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: Colors.grey.shade800,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade700,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, ),
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Column(
        children: List.generate(6, (i) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 36, height: 36, radius: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: double.infinity, height: 13),
                        const SizedBox(height: 6),
                        ShimmerBox(width: 220, height: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < 5) Divider(color: Theme.of(context).dividerColor, height: 1, thickness: 1),
          ],
        )),
      ),
    );
  }
}