class Course {
  final int id;
  final String title;
  final String summary;
  final String instructor;
  final String category;
  final String level;
  final String thumbnailUrl;
  final int lessonCount;
  final int totalDurationMinutes;

  const Course({
    required this.id,
    required this.title,
    required this.summary,
    required this.instructor,
    required this.category,
    required this.level,
    required this.thumbnailUrl,
    required this.lessonCount,
    required this.totalDurationMinutes,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as int,
    title: json['title'] as String,
    summary: json['summary'] as String,
    instructor: json['instructor'] as String,
    category: json['category'] as String,
    level: json['level'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String,
    lessonCount: json['lessonCount'] as int,
    totalDurationMinutes: json['totalDurationMinutes'] as int,
  );
}

class Lesson {
  final int id;
  final int courseId;
  final int order;
  final String title;
  final int durationSeconds;
  final String videoUrl;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    required this.durationSeconds,
    required this.videoUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as int,
    courseId: json['courseId'] as int,
    order: json['order'] as int,
    title: json['title'] as String,
    durationSeconds: json['durationSeconds'] as int,
    videoUrl: json['videoUrl'] as String,
  );
}

class CourseDetail {
  final int id;
  final String title;
  final String description;
  final String instructor;
  final String category;
  final String level;
  final String thumbnailUrl;
  final List<Lesson> lessons;

  const CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.category,
    required this.level,
    required this.thumbnailUrl,
    required this.lessons,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return CourseDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      instructor: json['instructor'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      lessons: lessons,
    );
  }
}