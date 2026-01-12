# TM Share
 ## A tool to share Trackmania Maps easily (import/export)

Trailer : https://www.youtube.com/watch?v=zQfv4YcwyRU

 Supports Trackania 2020 maps.
 
 You can now share your maps with local dependencies with a single zip file, and import it right away !
 
 Made in Godot 4.5.1. Support Linux and Windows.
 English and French translations.
 
 If you want you can test it out with my maps :
 https://github.com/ColorMan777/TrackMania-Maps/


 ## HOW TO USE ?

### First Startup
The first time you will launch TMShare, it will try to detect your Trackmania installation.
<img width="1208" height="733" alt="Screenshot_20260112_104910" src="https://github.com/user-attachments/assets/eec161f6-40f5-446d-a690-00ed4a641fce" />

If your Trackmania user folder isn't detected, you can try to find it by hand.   
On Windows, the user data folder is most often in ```C:\Documents\Trackmania for example.```  
Or ```D:\Documents\Trackmania``` if you have 2 partitions.  
On Linux, for the steam installation it's located in ```/home/<user>/.steam/debian-installation/steamapps/compatdata/2225070/pfx/drive_c/users/steamuser/Documents/Trackmania/```
<img width="1208" height="733" alt="Screenshot_20260112_104931" src="https://github.com/user-attachments/assets/0082d8f0-f5c3-4019-b6ac-e3af7c721c7e" />
Once you find and setup you Trackmania folder if necessary, you'll be able to use TM Share !

### Main Menu

On the main menu, you can choose import or export mode.
<img width="1208" height="733" alt="Screenshot_20260112_105102" src="https://github.com/user-attachments/assets/27e4ae26-3acb-45fc-983e-250374b0b515" />

### Export Mode

In export mode, TM Share will automatically list all your maps in ```-/Trackmania/Maps/My Maps/``` folder. If your maps aren't in this folder, you'll need to move them here.  
Once you have selected all the maps you want to export, you can choose a folder where all the maps will be exported.  
After that click export to export the maps in the folder. (It will create ZIP files for each maps)  

<img width="1208" height="733" alt="Screenshot_20260112_105119" src="https://github.com/user-attachments/assets/f837c149-8eae-4baa-a395-0b79b058b968" />

### Import Mode

In import mode, you can click the button or drag and drop zip files directly onto the application to start the import process.

<img width="1208" height="733" alt="Screenshot_20260112_105138" src="https://github.com/user-attachments/assets/f6f3d05e-a9e3-48f2-b09f-6e6a6c3857fe" />

Once it's done, TM Share will list all the maps names. If the names are correct, you can click "Import" and TM Share will automatically import all the maps in  ```-/Trackmania/Maps/My Maps/``` folder.

<img width="1208" height="733" alt="Screenshot_20260112_105225" src="https://github.com/user-attachments/assets/e3622196-04f7-4e77-978e-93f7cec088b5" />



 ## HOW DOES IT WORK ?

Basically the app reads .Gbx maps and copy dependencies along in a zip (+ create a JSON in the archive).  
In import mode it automatically extract maps in "My Maps" Folder and dependencies where they need to be based on their original path.  
You can do batch import / export with it to speed up the process.


 
<img width="1920" height="1080" alt="TmShare_Splash" src="https://github.com/user-attachments/assets/cd6aca5e-cc1f-4f34-9f57-40a514736e13" />
