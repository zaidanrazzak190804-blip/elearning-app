import 'package:go_router/go_router.dart';

import '../../features/courses/presentation/course_detail_page.dart';
import '../../features/courses/presentation/course_list_page.dart';
import '../../features/player/presentation/lesson_player_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CourseListPage(),
    ),
    GoRoute(
      path: '/course/:courseId',
      builder: (context, state) => CourseDetailPage(
        courseId: int.parse(state.pathParameters['courseId']!),
      ),
    ),
    // Placeholder sementara, diganti halaman player di langkah berikutnya.
    GoRoute(
      path: '/course/:courseId/lesson/:lessonId',
      builder: (context, state) => LessonPlayerPage(
        courseId: int.parse(state.pathParameters['courseId']!),
        lessonId: int.parse(state.pathParameters['lessonId']!),
      ),
    ),
  ],
);