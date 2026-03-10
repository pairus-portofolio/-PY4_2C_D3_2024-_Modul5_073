import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

part 'log_model.g.dart';

@HiveType(typeId: 0)
class LogModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final String authorId;

  @HiveField(5)
  final String teamId;

  @HiveField(6)
  final String category; // TAMBAHAN

  @HiveField(7)
  final bool isSynced; // TAMBAHAN

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.authorId,
    required this.teamId,
    required this.category,
    this.isSynced = true, // default true untuk data dari cloud
  });

  Map<String, dynamic> toMap() => {
    '_id': id != null ? ObjectId.fromHexString(id!) : ObjectId(),
    'title': title,
    'description': description,
    'date': date,
    'authorId': authorId,
    'teamId': teamId,
    'category': category,
    'isSynced': isSynced,
  };

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: (map['_id'] as ObjectId?)?.oid,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      authorId: map['authorId'] ?? 'unknown',
      teamId: map['teamId'] ?? 'no_team',
      category: map['category'] ?? 'software',
      isSynced: true, // Data dari DB Cloud selalu dianggap sudah sinkron
    );
  }

  LogModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? authorId,
    String? teamId,
    String? category,
    bool? isSynced,
  }) {
    return LogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      authorId: authorId ?? this.authorId,
      teamId: teamId ?? this.teamId,
      category: category ?? this.category,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
