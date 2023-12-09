# ethernally

### Your scrcpy companion for Android wireless screen mirroring

![alt text](https://i.imgur.com/0DEj5A8.png)

<details>
  <summary>Features</summary>
 
* Mirrors your screen wirelessly with scrcpy
* New! Support for non-rooted devices
* New! Supports Android 14
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
* You need an USB cable for first time setup and eventually later for fixing other potential connectivity issues - in USB debugging mode. If the tool asks for it, just plug it between your device and your PC while having USB debugging enabled. 
* To unlock the hidden Developer tools/options menu, go to Android Settings > About > Press on 'build number' 7 times. Then go to android settings > developer tools/options and enable USB debugging
* Also, under developer tools -> default USB configuration -> set to 'No data transfer' (https://github.com/Genymobile/scrcpy/issues/597)
* Note: perl is required (should be installed by default on most linux systems, but needs to be installed if using cygwin)
* Warning: live wallpapers might decrease mirroring performance
* Warning: lock screen and app lock will show black in the mirrored screen (Android 12+) (https://github.com/Genymobile/scrcpy/issues/3413)
* Warning: if you encounter any bug, it might be actually related to scrcpy rather than ethernally
* Warning: if device gets locked, connection might be killed (https://github.com/Genymobile/scrcpy/issues/3334)
</details>

<details>
  <summary>How To Run</summary> 

* Simply run the script from its folder (`cd ethernally`) and follow the intuitive wizard guide
* On first time attempt, you should turn on 'disable adb authorization timeout' under android developer settings. This disables automatic revocation of adb authorizations for systems that have not reconnected within the default (7 days) or user-configured (minimum 1 day) amount of time. However this could lower the security of your device!
* Note: Wireless debugging is not needed to be enabled under developer options
* On first time attempt, USB cable will be required and you must set cable in transfer mode to enable debug mode. Afterwards, authorize the device and check the box to remember
* 
```
chmod +x ethernally.sh # make the script executable (run only once)
dos2unix ethernally.sh # situational: might be needed to convert line endings to unix format (eg. when using Github for Desktop) (run only once)
./ethernally.sh
```
* You could also add ethernally folder to system path (linux) or to the environment variable PATH (windows), and call it from terminal (eg. `ethernally.sh`)
* Alternatively, you could create a symlink in your preferred location (eg. on your Linux Desktop)
* You could even add a shortcut on Windows (cygwin) to launch screen mirroring upon execution. To do that, set shortcut's target similar to this:
```
C:\cygwin\bin\mintty.exe /usr/bin/bash --login "/cygdrive/c/GitHub/ethernally/ethernally.sh"
```
* See also scrcpy shortcuts (using ALT key) to manage your mirrored device: https://github.com/Genymobile/scrcpy/blob/master/doc/shortcuts.md
```
USEFUL ACTION SHORTCUTS
#MOD = alt key
HOME	MOD+h | Middle-click
BACK	MOD+b | Right-click²
APP_SWITCH	MOD+s
Switch fullscreen mode	MOD+f
Rotate device screen	MOD+r
Turn device screen off (keep mirroring)	MOD+o
Turn device screen on	MOD+Shift+o
Power on	Right-click (if previously locked)
POWER BUTTON	MOD+p (aka lock/unlock OR long press for power menu OR very long press for power off)
Click on VOLUME_UP	MOD+↑ (up)
Click on VOLUME_DOWN	MOD+↓ (down)
Resize window to remove black borders	MOD+w
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

