import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/providers/post_notifier.dart';

class PollWidget extends ConsumerWidget {
  final List<PollOption> options;
  final String postId;
  final String currentUid;

  const PollWidget({
    super.key,
    required this.options,
    required this.postId,
    required this.currentUid,
  });

  bool get _hasVoted =>
      options.any((o) => o.voterUids.contains(currentUid));

  int get _totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final voted = option.voterUids.contains(currentUid);
          final percentage =
              _totalVotes > 0 ? option.votes / _totalVotes : 0.0;

          if (_hasVoted) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.text,
                          style: TextStyle(
                            fontWeight:
                                voted ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: voted ? AppColors.primary : AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: OutlinedButton(
              onPressed: () {
                ref
                    .read(postNotifierProvider.notifier)
                    .votePoll(postId, index, currentUid);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Text(option.text),
            ),
          );
        }),
        Text(
          '$_totalVotes voto${_totalVotes == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
