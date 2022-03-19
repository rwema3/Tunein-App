



import 'dart:math';
import 'package:uuid/uuid.dart' as uuid;
class MathUtils{

  static int getRandomFromRange(int min, int max){
    Random rnd;
    rnd = new Random();
    return min + rnd.nextInt(max - min);
  }

  static String getUniqueId(){
    return uuid.Uuid().v4();
  }

}