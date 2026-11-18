import 'package:go_router/go_router.dart';

import '../../features/courses/presentation/course_list_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CourseListPage(),
    ),
    // Route detail course dan player ditambahkan di langkah berikutnya.
  ],
);