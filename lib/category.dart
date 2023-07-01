class Category {
  final String categoryName;
  final List<Question> questions;

  Category.fromJson(Map<String, dynamic> json)
  :
    categoryName = json['category_name'],
    questions = List<Question>.from(json['questions'].map((question) => Question.fromJson(question)));

  Map<String, dynamic> toJson() =>
      {  
        'category_name': categoryName,
        'questions': questions,
      };
}

class Question {
  final String full;
  final String short;
  final String type;
  final String id;

  Question.fromJson(Map<String, dynamic> json)
  :
    full = json['full_question'],
    short = json['short_question'],
    type = json['type'],
    id = json['identifier'];

  Question(this.full, this.short, this.type, this.id);
  
}