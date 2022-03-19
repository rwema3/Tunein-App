import 'dart:async';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';


enum QueueState{
  STARTING,
  PAUSED,
  ONGOING,
  STOPPED
}


class QueueService {

  BehaviorSubject<List<QueueItem>> _queue$;

  BehaviorSubject<List<QueueItem>> get queue$ => _queue$;

  int currentIndexProcess=0;
  QueueState currentQueueState =QueueState.STOPPED;
  Duration queueInterval=Duration(minutes: 1);
  Timer currentRunner;
  List<QueueItem> AlreadyExecutedItems=[];
  VoidCallback onQueueEndCallback;

  QueueService(){
    _initStream();
  }

  /// Sets a callback that would be called when the queue finishes on it's own ( all items have been processed )
  void setOnQueueEnd(VoidCallback callback){
    this.onQueueEndCallback=callback;
  }

  bool addItemsToQueue(QueueItem item){
    List<QueueItem> queue = _queue$.value;
    queue.add(item);
    _queue$.add(queue);
    return true;
  }

  removeItemFromQueue(QueueItem item, {int index}){
    if(item!=null){
      List<QueueItem> queue = _queue$.value;
      queue.removeWhere((Qitem){
        return Qitem.id == item.id;
      });

      _queue$.add(queue);
    }else{
      if(index!=null){
        List<QueueItem> queue = _queue$.value;
        queue.removeAt(index);

        _queue$.add(queue);
      }
    }
  }


  Future<bool> startQueue() async{
    if(currentQueueState!=QueueState.ONGOING && currentQueueState!=QueueState.STARTING){
      switch(currentQueueState){

        case QueueState.PAUSED:
        //resume the queue
          currentRunner?.cancel();
          QueueRunnerStart();
          currentQueueState= QueueState.ONGOING;
          break;
        case QueueState.STOPPED:
        //start the queue
          currentRunner?.cancel();
          currentQueueState= QueueState.STARTING;
          print("queue will start");
          QueueRunnerStart();
          break;

        default:
          break;
      }
    }else{
      print("can't start queue, an other one que is already starting or is ongoing");
    }
  }

  Future<bool> pauseQueue() async{
    if(currentQueueState!=QueueState.PAUSED && currentQueueState!=QueueState.STOPPED){
      switch(currentQueueState){

        case QueueState.STARTING:
        //stop the queue
          currentRunner?.cancel();
          currentRunner=null;
          currentQueueState=QueueState.PAUSED;
          break;
        case QueueState.ONGOING:
        //stop the queue
          currentRunner?.cancel();
          currentRunner=null;
          currentQueueState=QueueState.PAUSED;
          break;

        default:
          break;
      }
    }
  }

  Future<bool> stopQueue() async{
    if(currentQueueState!=QueueState.PAUSED && currentQueueState!=QueueState.STOPPED){
      print("queue going to stop");
      switch(currentQueueState){

        case QueueState.STARTING:
        //stop the queue
        currentRunner?.cancel();
        currentRunner=null;
        currentIndexProcess=0;
        AlreadyExecutedItems=[];
        currentQueueState=QueueState.STOPPED;
          break;
        case QueueState.ONGOING:
        //stop the queue
        currentRunner?.cancel();
        currentRunner=null;
        currentIndexProcess=0;
        AlreadyExecutedItems=[];
        currentQueueState=QueueState.STOPPED;
          break;

        default:
          break;
      }
      return true;
    }else{
      return true;
    }
  }


  Future<bool> resumeRunner() async{
    if(currentRunner==null && currentQueueState!=QueueState.ONGOING && currentQueueState!=QueueState.STARTING){
      QueueRunnerStart();
    }else{
      print("queue is either starting or ongoing, can't resume");
    }
  }




  QueueRunnerStart(){
    print("queue is starting");
    currentRunner = Timer.periodic(queueInterval, (timer){
     List<QueueItem> queue =  _queue$.value;
     currentQueueState = QueueState.ONGOING;
     if(queue.length<=currentIndexProcess+1){
       stopQueue();
       if(onQueueEndCallback!=null){
         onQueueEndCallback();
       }
       return;
     }
     if(queue[currentIndexProcess].execute !=null){
       print("will execute processs of item ${queue[currentIndexProcess].name}");
       queue[currentIndexProcess].execute().then((data){
         AlreadyExecutedItems.add(queue[currentIndexProcess]);
         if(data==true){
           print(" execute processs of item ${queue[currentIndexProcess].name} has been done");
           queue[currentIndexProcess].state=QueueItemState.COMPLETED;
           currentIndexProcess++;
         }else{
           if(data==false){
             //this should add the queue Item to the end of the queue for a subsequent try at executing
             //This is not implemented yet
           }
         }
       }).catchError((err){
         queue[currentIndexProcess].state=QueueItemState.ERRORED;
         currentIndexProcess++;
       });
     }else{
       currentIndexProcess++;
     }
   });
  }


  _initStream(){
    _queue$ = BehaviorSubject<List<QueueItem>>.seeded([]);
  }

  void dispose() {
    stopQueue();
    currentRunner.cancel();
    _queue$.close();
  }

}

enum QueueItemState{
  IDLE,
  STARTED,
  ERRORED,
  COMPLETED
}


class QueueItem {
  String id;
  String name;
  Future<bool> Function() execute;
  QueueItemState state;

  QueueItem({this.name, this.execute, this.state = QueueItemState.IDLE}){
   this.id= Uuid().v1();
  }


}