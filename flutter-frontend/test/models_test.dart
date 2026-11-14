import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_frontend/models/user_model.dart';
import 'package:flutter_frontend/models/student_model.dart';
import 'package:flutter_frontend/models/instructor_model.dart';
import 'package:flutter_frontend/models/course_model.dart';
import 'package:flutter_frontend/models/lecture_model.dart';

void main() {
  group('Models Serialization Test', () {
    test('UserModel fromJson and toJson', () {
      final json = {
        'id': 'usr_123',
        'name': 'Dr. Test',
        'email': 'test@apex.edu',
        'role': 'teacher',
        'instituteCode': 'INST-2025',
        'instituteName': 'Apex Institute',
        'department': 'Computer Science',
      };
      final user = UserModel.fromJson(json);
      expect(user.id, 'usr_123');
      expect(user.name, 'Dr. Test');
      expect(user.role, 'teacher');
      expect(user.instituteCode, 'INST-2025');

      final serialized = user.toJson();
      expect(serialized['id'], 'usr_123');
      expect(serialized['name'], 'Dr. Test');
    });

    test('StudentModel fromJson and toJson', () {
      final json = {
        'id': 'std_101',
        'name': 'Rahul Sharma',
        'email': 'rahul@institute.com',
        'rollNumber': '1023',
        'className': 'BCA - Sem 3',
        'course': 'BCA',
        'phone': '+91 98765 43210',
      };
      final student = StudentModel.fromJson(json);
      expect(student.name, 'Rahul Sharma');
      expect(student.rollNumber, '1023');
      expect(student.className, 'BCA - Sem 3');

      final serialized = student.toJson();
      expect(serialized['name'], 'Rahul Sharma');
      expect(serialized['rollNumber'], '1023');
    });

    test('InstructorModel fromJson and toJson', () {
      final json = {
        'id': 'ins_01',
        'name': 'Dr. Amit Sharma',
        'email': 'amit.sharma@institute.com',
        'instructorId': 'INS-001',
        'department': 'Computer Science',
        'designation': 'Assistant Professor',
      };
      final instructor = InstructorModel.fromJson(json);
      expect(instructor.name, 'Dr. Amit Sharma');
      expect(instructor.instructorId, 'INS-001');
      expect(instructor.department, 'Computer Science');
    });

    test('CourseModel and LectureModel', () {
      final course = CourseModel(
        id: 'c1',
        code: 'CS-301',
        name: 'DBMS',
        department: 'CS',
        credits: 4,
        semester: 'Sem 3',
        studentsEnrolled: 48,
        progress: 0.75,
      );
      expect(course.code, 'CS-301');
      expect(course.credits, 4);

      final lecture = LectureModel(
        id: 'l1',
        title: 'DBMS Lecture',
        courseCode: 'CS-301',
        courseName: 'DBMS',
        date: 'May 10',
        time: '10:00 AM',
        room: 'Hall 302',
        topic: 'Normalization',
      );
      expect(lecture.room, 'Hall 302');
      expect(lecture.status, 'Scheduled');
    });
  });
}

