import 'package:dio/dio.dart';
import 'course_models.dart';

class CourseRepository {
  final Dio _dio;
  CourseRepository(this._dio);

  Future<List<Course>> getCourses() async {
    final res = await _dio.get('/courses.json');
    final list = res.data['data'] as List;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CourseDetail> getCourseDetail(int id) async {
    final res = await _dio.get('/courses/$id.json');
    return CourseDetail.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}