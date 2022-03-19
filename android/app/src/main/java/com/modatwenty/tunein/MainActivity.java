package com.modatwenty.tunein;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.UriPermission;
import android.net.Uri;
import android.os.Bundle;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.Nullable;
import androidx.documentfile.provider.DocumentFile;
import androidx.palette.graphics.Palette;

import android.media.MediaMetadataRetriever;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import android.os.Environment;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.util.Log;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "android_app_retain";
  private static final MediaMetadataRetriever mmr = new MediaMetadataRetriever();
  private MethodChannel methodChannel;

  public static int getDominantColor(Bitmap bitmap) {
    Bitmap newBitmap = Bitmap.createScaledBitmap(bitmap, 1, 1, true);
    final int color = newBitmap.getPixel(0, 0);
    newBitmap.recycle();
    return color;

  }

  public void takeCardUriPermission(String sdCardRootPath) {
    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
      File sdCard = new File(sdCardRootPath);
      StorageManager storageManager = (StorageManager) getSystemService(Context.STORAGE_SERVICE);
      StorageVolume storageVolume = storageManager.getStorageVolume(sdCard);
      Intent intent = storageVolume.createAccessIntent(null);
      try {
        startActivityForResult(intent, 4010);
      } catch (ActivityNotFoundException e) {
        Log.e("TUNE-IN ANDROID", "takeCardUriPermission: "+e);
      }
    }
  }

  protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    if (requestCode == 4010) {

      Uri uri = data.getData();

      grantUriPermission(getPackageName(), uri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION |
              Intent.FLAG_GRANT_READ_URI_PERMISSION);

      final int takeFlags = data.getFlags() & (Intent.FLAG_GRANT_WRITE_URI_PERMISSION |
              Intent.FLAG_GRANT_READ_URI_PERMISSION);

      getContentResolver().takePersistableUriPermission(uri, takeFlags);
      methodChannel.invokeMethod("resolveWithSDCardUri",getUri().toString());
    }
  }

  public Uri getUri() {
    List<UriPermission> persistedUriPermissions = getContentResolver().getPersistedUriPermissions();
    if (persistedUriPermissions.size() > 0) {
      UriPermission uriPermission = persistedUriPermissions.get(0);
      return uriPermission.getUri();
    }
    return null;
  }

  @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
            GeneratedPluginRegistrant.registerWith(flutterEngine);
    methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    methodChannel.setMethodCallHandler(
                  (methodCall, result) -> {
                    Map<String, Object> arguments = methodCall.arguments();
                    if (methodCall.method.equals("sendToBackground")) {
                      moveTaskToBack(true);
                    }

                    if (methodCall.method.equals("getStoragePath")) {
                      String path = Environment.getDataDirectory().toString();
                      result.success(path);
                    }

                    if(methodCall.method.equals("getSDCardPermission")){
                      takeCardUriPermission(getExternalCacheDirs()[1].toString());
                      result.success(true);
                    }

                    if(methodCall.method.equals("saveFileFromBytes")){
                      String filepath = (String) arguments.get("filepath");
                      final byte[] bytes = methodCall.argument("bytes");

                      try{
                        if(filepath==null || bytes==null)throw new Exception("Arguments Not found");
                        filepath=filepath.replace("%20"," ");
                        DocumentFile documentFile = DocumentFile.fromTreeUri(getApplicationContext(), getUri());
                        String[] parts = filepath.split("/");
                        for (int i = 0; i < parts.length; i++) {
                          if(documentFile.findFile(parts[i])!=null){
                            documentFile=documentFile.findFile(parts[i]);
                          }
                        }
                        if(documentFile!=null && documentFile.isFile()){
                          OutputStream out = getContentResolver().openOutputStream(documentFile.getUri());
                          out.write(bytes);
                          out.close();
                        }else{
                          throw new Exception("File Not Found");
                        }
                      }catch (Exception e){
                        result.error("400",e.getMessage(),e);
                        return;
                      }
                      result.success(true);
                    }

                    if (methodCall.method.equals("getMetaData")) {
                      String filepath = (String) arguments.get("filepath");
                      System.out.println(filepath);
                      List l = new ArrayList();
                      mmr.setDataSource(filepath);
                      l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE));
                      l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST));
                      try {
                        l.add(mmr.getEmbeddedPicture());
                      } catch (Exception e) {
                        l.add("");
                      }

                      l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM));
                      l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER));
                      l.add(mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION));
                      result.success(l);
                    }

                    if (methodCall.method.equals("getSdCardPath")) {
                      String removableStoragePath = null;
                      try {
                        removableStoragePath = getExternalCacheDirs()[1].toString();
                      } catch (Exception e) {
                      }
                      result.success(removableStoragePath);
                    }

                    if (methodCall.method.equals("getColor")) {
                      String path = methodCall.argument("path");

                      Bitmap myBitmap = BitmapFactory.decodeFile(path);
                      // int color = getDominantColor(myBitmap);
                      // String text = methodCall.argument("path");
                      // result.success(color);

                      Palette.generateAsync(myBitmap, new Palette.PaletteAsyncListener() {
                        int defaultColor = 0x000000;
                        List<Integer> colors = new ArrayList<Integer>();

                        public void onGenerated(Palette palette) {
                          Palette.Swatch dominantSwatch = palette.getDominantSwatch();

                          int backgroundColor = dominantSwatch.getRgb();
                          int textColor = dominantSwatch.getBodyTextColor();
                          int titleColor = dominantSwatch.getTitleTextColor();

                          colors.add(backgroundColor);
                          colors.add(titleColor);
                          colors.add(textColor);

                          result.success(colors);
                        }
                      });
                    }

                  }
              );
        }


}
