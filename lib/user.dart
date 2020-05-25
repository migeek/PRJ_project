// todo: possibly use this to create user info
class User{
    int id;
    String name;
    String email;
    User({this.id, this.name, this.email});
    // converts User JSON representation to User object
    factory User.fromJSON(Map<String, dynamic> json){
      return User(
        id: json["id"] as int,
        name: json["name"] as String,
        email: json["email"] as String
      );
    }
    Map<String, dynamic> toJSON() => {
      "id": id,
      "name": name,
      "email": email
    };
}