# ethernally

## Your Android companion for wireless connectivity

### Features:
-Automatically adds wifi adb connection capability at boot
-Connects through adb via wifi
-Mirrors your screen wirelessly with scrcpy
-Starts a shell on your device
-Works in linux/cygwin
-Tackles all scenarios that could get you into issues. It even finds a way when wifi is turned off

!Note:
It might ask to plug USB cable (device-PC) for resolving potential connectivity issues in USB debugging



### Requires:
-scrpy installed or set to system PATH
-clone it from: https://github.com/Genymobile/scrcpy
-requires the android to be rooted (you can use magisk) to be able to modify Android props


### To run:
>clone from github
```
dos2unix ethernally.sh #might be needed to convert line endings to unix format
chmod +x ethernally.sh #make the script executable
```
>simply run the script from its folder and follow the wizzard guide
```
./ethernally.sh
```
