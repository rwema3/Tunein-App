


import 'dart:io';

class HttpOutgoingServer {


  HttpServer currentServer;
  Map<String, SimpleRequest> callbacks = new Map();


  HttpOutgoingServer({bool doCreateServer = true, String ip, String port, bool newSharedServer=true, bool initiateListeningImmediately = true}){
    if(doCreateServer){
      createServer(ip??"0.0.0.0", port??"8090", shared: newSharedServer, initiateImmediately: initiateListeningImmediately);
    }
  }

  Future createServer (String ip, String port, {bool shared = true, bool initiateImmediately = true}) async{
    int intPort =  int.parse(port, radix: 10,  onError: (err)=>throw "Server port is incorrect");
    try{
      currentServer = await HttpServer.bind(ip, intPort);
      if(initiateImmediately){
        startListening();
      }
    }catch(e){
      print("Http Server Not initiated");
      print("currentServer is : $currentServer");
      print(e);
      print(e.stack);
    }
  }


  void startListening(){
    if(currentServer==null) throw "No Server to listen on";
    currentServer.listen((request) {
      if(callbacks.containsKey(request.uri.path)){
        SimpleRequest req = callbacks[request.uri.path];
        if(req.method.contains(request.method)){
          if(req.callback!=null){
            req.callback(request).then((value){
              if(value!=null){
                try{
                  request.response.write(value);
                  request.response.close();
                }catch(e){
                  print("error when writing to the response");
                  print(e);
                  print(e.stack);
                }
              }
            });
          }
        }else{
          _sendWrongMethodFound(request.response);
        }
      }else{
        _sendNotFound(request.response);
      }

    });
  }


  Future<bool> stopCurrentHTTPServer({bool forceStop=false}){
    if(currentServer!=null){
      return currentServer.close(force: forceStop);
    }
    return Future.value(true);
  }

  void addListenerCallback(SimpleRequest request){
    callbacks[request.URL] =  request;
  }

  void removeListenerCallback(String URL){
    callbacks.remove(URL);
  }


  _sendNotFound(HttpResponse response) {
    response.write('Not found');
    response.statusCode = HttpStatus.notFound;
    response.close();
  }

  _sendWrongMethodFound(HttpResponse response) {
    response.write('Bad Method');
    response.statusCode = HttpStatus.notFound;
    response.close();
  }
}



class SimpleRequest {
  List<String> method;
  String URL;
  Future Function(HttpRequest) callback;
  SimpleRequest({this.method, this.URL, this.callback});
}