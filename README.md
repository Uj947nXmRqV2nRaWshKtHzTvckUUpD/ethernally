# ethernally

### Your Android companion for wireless screen mirroring

![alt text](https://i.imgur.com/0DEj5A8.png)

<details>
  <summary>Features</summary>
 
* Mirrors your screen wirelessly with scrcpy
* Automatically adds wifi adb connection capability at boot [root only]
* Connects through adb via WiFi
* Remembers last known working WiFi IP for fast connection
* Drops you to a wireless shell on the device
* Works in Linux and in Windows via cygwin or WSL (Windows Subsystem for Linux)
* Tackles all scenarios that could get you into issues. It even finds a way when wifi is turned off!
</details>


<details>
<summary>Requirements</summary> 

* scrpy installed or set to system PATH (clone from: https://github.com/Genymobile/scrcpy)
* requires the android to be rooted (you can use magisk). This is required to permanently set Android props to allow WiFi adb connections at all times
* It might ask to plug USB cable (device-PC) for resolving potential connectivity issues in USB debugging mode
</details>

<details>
  <summary>How To Run</summary> 
  
```
dos2unix ethernally.sh #might be needed to convert line endings to unix format
chmod +x ethernally.sh #make the script executable
```
>simply run the script from its folder (`cd ethernally`) and follow the wizzard guide
```
./ethernally.sh
```
>you could also add it to system path (linux) or to the environment variables (cygwin), and call it from anywhere
>alternatively you could create a symlink in your preferred location (eg. Desktop)
>you could even add a shortcut on windows to launch screen mirroring upon execution. To do that, set shortcut's target similar to this:
```
C:\cygwin\bin\mintty.exe /usr/bin/bash --login "/cygdrive/c/GitHub/ethernally/ethernally.sh"
```
  </details>
