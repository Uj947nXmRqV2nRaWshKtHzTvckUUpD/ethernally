# ethernally

### Your scrcpy companion for Android wireless screen mirroring

![alt text](https://i.imgur.com/0DEj5A8.png)

<details>
  <summary>Features</summary>
 
* Mirrors your screen wirelessly with scrcpy
* New! Support for non-rooted devices
* New! Supports Android 11
* Automatically adds Wi-Fi adb connection capability at boot [root only]
* Connects through adb via Wi-Fi or USB cable
* Remembers last known working Wi-Fi IP for fast connection
* Works even when authorization was revoked due to expiration (Android 11)
* Drops you to a wireless shell on the device
* Works in Linux and in Windows via cygwin or WSL (Windows Subsystem for Linux)
* Tackles all scenarios that could get you into issues. It even finds a way when Wi-Fi is turned off!
* POSIX compatible
</details>


<details>
<summary>Requirements</summary> 

* scrpy must be installed or set to system PATH (clone from: https://github.com/Genymobile/scrcpy)
* To permanently set Android props to allow Wi-Fi adb connections at all times, it is required to have the device rooted (you can use magisk).
* You might need an USB cable for resolving potential connectivity issues in USB debugging mode. If the tool asks for it, just plug it between your device and your PC while having USB debugging enabled. (To unlock the hidden Developer tools/options menu, go to Android Settings > About > Press on 'build number' 7 times. Then go to android settings > developer tools/options and enable USB debugging)
</details>

<details>
  <summary>How To Run</summary> 

* Prerequisites:
```
dos2unix ethernally.sh #optional, might be needed to convert line endings to unix format (eg. when using Github for Desktop)
chmod +x ethernally.sh #make the script executable
```
* Simply run the script from its folder (`cd ethernally`) and follow the intuitive wizard guide:
```
./ethernally.sh
```
* You could also add it to system path (linux) or to the environment variables (cygwin), and call it from anywhere (eg. `ethernally`)
* Alternatively, you could create a symlink in your preferred location (eg. on your Linux Desktop)
* You could even add a shortcut on Windows (cygwin) to launch screen mirroring upon execution. To do that, set shortcut's target similar to this:
```
C:\cygwin\bin\mintty.exe /usr/bin/bash --login "/cygdrive/c/GitHub/ethernally/ethernally.sh"
```
  </details>

<details>
  <summary>How To Update</summary>
  
* To update the script, simply pull latest changes from the git repository:
  
```
git pull
```
* Alternatively you could just copy/paste the code into your script or download it again (eg. with `wget`)
  </details>

### Feel free to contribute

