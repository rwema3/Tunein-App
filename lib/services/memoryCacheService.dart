enum CachedItems{
  SDCARD_NAME
}

class MemoryCacheService{


  Map<String, dynamic> primaryCache;


  MemoryCacheService(){
    init();
  }

  dynamic setCacheItem(dynamic id, dynamic value){
    if(id is CachedItems){
      primaryCache[id.toString()] = value;
      return;
    }
    primaryCache[id] = value;
    return;
  }

  dynamic getCacheItem(dynamic id){
    if(id is CachedItems){
      return primaryCache[id.toString()];
    }
    return primaryCache[id];
  }

  bool isItemCached(String id){
    if(id is CachedItems){
      return primaryCache.containsKey(id.toString());
    }
    return primaryCache.containsKey(id);
  }




  init(){
    primaryCache= new Map();
  }
}