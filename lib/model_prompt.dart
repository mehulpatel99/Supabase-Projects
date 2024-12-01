class PromptModel {
  int? id;
  String? title;
  String? prompt;
  String? userId;
  String? createdAt;
  String? imageUrl;
  String? userName;
  Users? users;

  PromptModel(
      {this.id,
        this.title,
        this.prompt,
        this.userId,
        this.createdAt,
        this.imageUrl,
        this.users,
        this.userName
      });

  PromptModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    prompt = json['prompt'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    imageUrl = json['imageUrl'];
    userName = json['userName'];
    users = json['users'] != null ? new Users.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['prompt'] = this.prompt;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['imageUrl'] = this.imageUrl;
    data['userName'] = this.userName;
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
  String? phone;

  Metadata({this.name,this.phone});

  Metadata.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['phone'] = this.phone;
    return data;
  }
}
