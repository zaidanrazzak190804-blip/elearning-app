import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../data/course_models.dart';
import '../data/course_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final courseRepositoryProvider = Provider<CourseRepository>(
      (ref) => CourseRepository(ref.watch(dioProvider)),
);

// retry dimatikan supaya state error langsung tampil (Riverpod 3 otomatis
// mengulang provider yang gagal secara default).
final coursesProvider = FutureProvider<List<Course>>(
      (ref) => ref.watch(courseRepositoryProvider).getCourses(),
  retry: (retryCount, error) => null,
);

final courseDetailProvider = FutureProvider.family<CourseDetail, int>(
      (ref, id) => ref.watch(courseRepositoryProvider).getCourseDetail(id),
  retry: (retryCount, error) => null,
);