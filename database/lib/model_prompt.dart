class PromptModel {
  int? id;
  String? title;
  String? prompt;
  String? userId;
  String? createdAt;
  Users? users;

  PromptModel(
      {this.id,
        this.title,
        this.prompt,
        this.userId,
        this.createdAt,
        this.users});

  PromptModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    prompt = json['prompt'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    users = json['users'] != null ? new Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['prompt'] = this.prompt;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}

class Users {
  String? email;
  Metadata? metadata;

  Users({this.email, this.metadata});

  Users.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    metadata = json['metadata'] != null
        ? new Metadata.fromJson(json['metadata'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    if (this.metadata != null) {
      data['metadata'] = this.metadata!.toJson();
    }
    return data;
  }
}

class Metadata {
  String? name;

  Metadata({this.name});

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}
