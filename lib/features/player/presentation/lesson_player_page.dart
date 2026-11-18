import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../courses/presentation/state_views.dart';
import '../../courses/providers/course_providers.dart';
import 'lesson_video_player.dart';

class LessonPlayerPage extends ConsumerStatefulWidget {
  final int courseId;
  final int lessonId;
  const LessonPlayerPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends ConsumerState<LessonPlayerPage> {
  late int _lessonId = widget.lessonId;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: friendlyError(error),
          onRetry: () =>
              ref.invalidate(courseDetailProvider(widget.courseId)),
        ),
        data: (course) {
          final lesson =
              course.lessons.where((l) => l.id == _lessonId).firstOrNull;
          if (lesson == null) {
            return const EmptyView(message: 'Lesson tidak ditemukan.');
          }
          final textTheme = Theme.of(context).textTheme;

          return ListView(
            children: [
              // key berbeda tiap lesson -> player lama di-dispose, player baru dibuat
              LessonVideoPlayer(
                key: ValueKey(lesson.id),
                videoUrl: lesson.videoUrl,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.title, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(course.title, style: textTheme.bodySmall),
                    const SizedBox(height: 24),
                    Text('Lesson lainnya', style: textTheme.titleMedium),
                  ],
                ),
              ),
              for (final l in course.lessons)
                ListTile(
                  selected: l.id == _lessonId,
                  leading: CircleAvatar(child: Text('${l.order}')),
                  title: Text(l.title),
                  trailing: l.id == _lessonId
                      ? const Icon(Icons.equalizer)
                      : const Icon(Icons.play_circle_outline),
                  onTap: () {
                    if (l.id != _lessonId) setState(() => _lessonId = l.id);
                  },
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}