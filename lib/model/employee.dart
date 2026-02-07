import 'dart:convert';

class Employee {
  final int employeeId;
  final String name;
  final String designation;
  final String department;
  final String teamName;
  final String email;
  final String phoneNumber;

  Employee(
    this.employeeId,
    this.name,
    this.designation,
    this.department,
    this.teamName,
    this.email,
    this.phoneNumber,
  );

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'designation': designation,
      'department': department,
      'teamName': teamName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  static Employee fromString(String jsonString) {
    return fromJson(jsonDecode(jsonString));
  }

  static Employee fromJson(Map<String, dynamic> json) {
    return Employee(
      json['employeeId'],
      json['name'],
      json['designation'],
      json['department'],
      json['teamName'],
      json['email'],
      json['phoneNumber'],
    );
  }
}

// void main() {
//   Employee emp = Employee(
//     1,
//     "John Doe",
//     "Software Engineer",
//     "IT",
//     "Development",
//     "john.doe@example.com",
//     "123-456-7890",
//   );
//   String empString = emp.toString();
//   print("Employee as String: $empString");
//   Employee empFromString = Employee.fromString(empString);
//   print("Employee from String: ${empFromString.toJson()}");
// }
