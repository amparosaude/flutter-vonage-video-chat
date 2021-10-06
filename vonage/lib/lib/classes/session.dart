import 'package:meta/meta.dart';
class Session {
  final String id;
  final String token; 
  final String apiKey;

  Session({
    @required this.id,
    @required this.token,
    @required this.apiKey});

  Map<String,dynamic> toJson(){
    Map<String,dynamic> json = {};
    json["sessionId"] = this.id;
    json["token"] = this.token;
    json["apiKey"] = this.apiKey;
    return json;
  }
}

class SessionResponse {
  bool status;

  SessionResponse(this.status);

  SessionResponse.fromJson(Map json){
    try{
      if(!json.keys.toSet().containsAll(['success'])){
        throw "Session response - format incorrect";
      }
      this.status = json['success'];
    } catch (err){
      throw err;
    }
  }
}