import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_error.dart';
import '../data/course_models.dart';
import '../providers/course_providers.dart';
import 'state_views.dart';

class CourseDetailPage extends ConsumerWidget {
  final int courseId;
  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Course')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: friendlyError(error),
          onRetry: () => ref.invalidate(courseDetailProvider(courseId)),
        ),
        data: (course) => _DetailContent(course: course),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final CourseDetail course;
  const _DetailContent({required this.course});

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            course.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${course.instructor} • ${course.level}',
                  style: textTheme.bodySmall),
              const SizedBox(height: 12),
              Text(course.description),
              const SizedBox(height: 24),
              Text('Daftar Lesson', style: textTheme.titleMedium),
            ],
          ),
        ),
        if (course.lessons.isEmpty)
          const EmptyView(message: 'Belum ada lesson di course ini.')
        else
          for (final lesson in course.lessons)
            ListTile(
              leading: CircleAvatar(child: Text('${lesson.order}')),
              title: Text(lesson.title),
              subtitle: Text(_formatDuration(lesson.durationSeconds)),
              trailing: const Icon(Icons.play_circle_outline),
              onTap: () => context.push(
                '/course/${course.id}/lesson/${lesson.id}',
              ),
            ),
        const SizedBox(height: 24),
      ],
    );
  }
}