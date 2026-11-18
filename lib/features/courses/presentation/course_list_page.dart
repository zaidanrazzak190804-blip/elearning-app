import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../data/course_models.dart';
import '../providers/course_providers.dart';
import 'state_views.dart';

class CourseListPage extends ConsumerWidget {
  const CourseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Course')),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          message: friendlyError(error),
          onRetry: () => ref.invalidate(coursesProvider),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return const EmptyView(message: 'Belum ada course tersedia.');
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(coursesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => CourseCard(
                course: courses[i],
                onTap: () => context.push('/course/${courses[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const CourseCard({super.key, required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                course.thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
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
                  Text(course.title, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(course.instructor, style: textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    course.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(label: Text(course.level)),
                      Chip(label: Text('${course.lessonCount} lesson')),
                      Chip(label: Text('${course.totalDurationMinutes} menit')),
                    ],
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