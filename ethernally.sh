#!/bin/sh

#this script automatically sets permanent adb via wifi and eventually start srccpy through WiFi

#set the default adbd listening port
port="5555"

#FUNCTIONS (order matters!)

function get_device_serial() {

    adb_devices=$(adb devices -l)
    #echo "adb_devices: ${adb_devices}"
    usb_device_serial=$(echo "${adb_devices}" | grep -w device | grep -v '\.' | awk '{print $1}') #get USB connected device serial

    echo "${usb_device_serial}"

}

function check_usb_connection() {

    while [[ -z "${usb_device_serial}" ]]; do

        usb_device_serial=$(get_device_serial)
        #echo "usb_device_serial: ${usb_device_serial}"

        usb_device=$(adb devices -l | grep -w device | grep -v '\.' | awk -F: '{print $4}' | awk '{print $1}') #get device name

        if [[ ! -z "${usb_device_serial}" ]]; then
            echo ""
            echo "device(s) connected via USB cable: ${usb_device}" #print USB conneted device serial
            break

        fi

        echo -n "."

        sleep 1 #wait to be ready

    done

}

function check_root() {

    echo "Checking root.."
    elevated_UID=$(adb -s "${device}" shell su --command "id -u" | sed 's/\r$//g')
    #trying to get attached device wlan0 ip
    #sed is required to fix line ending by removing dos carriage return (cygwin)
    #echo "elevated_UID: ${elevated_UID}"

    if [[ ${elevated_UID} != "0" ]]; then
        echo "Your device needs to be rooted for allowing permanent WiFi connectivity through ADB"
        rooted=0
        #echo "rooted: ${rooted}"
        #exit 1
    else
        echo "Device is rooted. Moving on.."
        echo ""
    fi

}

function get_wifi_connection() {

    check_usb_connection
    usb_device_serial=$(get_device_serial)


    adb -s "${usb_device_serial}" shell "svc wifi enable"


    while [[ -z "${wlan0_IP}" ]]; do

        wlan0_IP=$(adb -s "${usb_device_serial}" shell ip -f inet addr show wlan0 2>/dev/null |
            grep inet |
            awk '{print $2}' |
            awk -F [\/] '{print $1}')
        #get wlan0 ip

        if [[ ! -z "${wlan0_IP}" ]]; then
            echo "${wlan0_IP}" #print wlan0 ip
            break
        fi

    done

}

function set_last_working_device_info() {

    echo "${socket}" >${last_working_device}
    manufacturer=$(adb -s "${socket}" shell "getprop ro.product.manufacturer") #Manufacturer
    echo "Manufacturer: ${manufacturer}" >>${last_working_device}

    android_version=$(adb -s "${socket}" shell "getprop ro.build.version.release") #device android version
    echo "Android Version: ${android_version}" >>${last_working_device}

    sdk_version=$(adb -s "${socket}" shell "getprop ro.build.version.sdk") #sdk version
    echo "SDK Version: ${sdk_version}" >>${last_working_device}

    product_name=$(adb -s "${socket}" shell "getprop ro.product.name") #product name
    echo "Product Name: ${product_name}" >>${last_working_device}

    model=$(adb -s "${socket}" shell "getprop ro.product.model") #device model
    echo "Model: ${model}" >>${last_working_device}

}

function usb_connection() {

    #((device does not have WiFi turned on) OR (does not have an IP set)) OR (device is NOT already attached via (tcp/wifi OR USB))

    #try detecting plugged USB cable; debugging should be turned on, fingerprint accepted

    #disconnect any existing connection, kill any adb server on pc (to start from scratch). Not needed actually..
    #adb disconnect
    #adb kill-server
    #sleep 1

    echo ""
    echo "Please plug USB cable and enable USB debugging (To unlock the hidden Developer tools/options menu, go to Android Settings > About > Press on 'build number' 7 times. Then go to android settings > developer tools/options and enable USB debugging)"

    echo ""
    echo "Checking if USB cable is connected and USB debugging enabled.."

    check_usb_connection

    echo ""
    device=${usb_device_serial}

    #check if device is rooted
    check_root ${device}

    #if device is not rooted
    if [[ ${rooted} == 0 ]]; then
        echo "Device is not rooted. Moving on.."
        adb tcpip 5555
        sleep 3
    else

        #device rooted

        #Set props
        adb -s "${usb_device_serial}" shell su --command "setprop service.adb.tcp.port ${port}" &&
            echo -n "Property service.adb.tcp.port was set to:" &&
            adb -s "${usb_device_serial}" shell su --command "getprop service.adb.tcp.port" #set adbd session tcp port

        adb -s "${usb_device_serial}" shell su --command "setprop persist.adb.tcp.port ${port}" &&
            echo -n "Property persist.adb.tcp.port was set to:" &&
            adb -s "${usb_device_serial}" shell su --command "getprop persist.adb.tcp.port" #set adbd persistent(boot) tcp port

        echo "Restarting adbd"
        adb -s "${usb_device_serial}" shell "su --command 'stop adbd ; sleep 2 ; start adbd'" #restart adbd daemon to start listening on port (tcp/wifi); sleep is required to allow smooth service stop
        echo "Restarted adbd"

        sleep 5 #give adbd some time to restart. If sleeping less than 5 seconds, it might throw error: adb(.exe): no devices/emulators found

    fi

    # #detect manual wifi start. Not needed anymore
    # while [[ -z "${wlan0_IP}" ]]; do

    #     wlan0_IP=$(adb shell ip -f inet addr show wlan0 |
    #         grep inet |
    #         awk '{print $2}' |
    #         awk -F [\/] '{print $1}') #get wlan0 ip

    #     if [[ ! -z $wlan0_IP ]]; then
    #         echo "WiFi wlan0 IP: $wlan0_IP" #print wlan0 ip
    #         break
    #     fi

    #     echo "Please turn on WiFi on your device"
    #     read -p "Press enter when ready."

    #     sleep 3 #wait to be ready

    # done

    echo "Attempting to start Wi-Fi on the device.."
    wlan0_IP=$(get_wifi_connection)
    #echo "wlan0_IP: ${wlan0_IP}"
    socket="${wlan0_IP}:${port}"
    echo "new socket: ${socket}"

    status=$(adb connect ${socket})
    #adb returns exit code 0 even if cannot connect. not reliable...

    if [[ ${status} == *cannot* ]]; then
        echo "Could not connect via adb to WiFi device"
        connected="0"
    else #Wi-Fi connectivity worked
        echo "Connecting via wifi.."
        adb connect "${socket}" #reconnect to shell via wifi. You can unplug USB cable at this stage. scrcpy should work now

        #0 if failed ; 1 if connected
        connected="1"
        #echo "connected: ${connected}"

        #set last known working device
        set_last_working_device_info

        echo "Device ready!"

        echo ""
    fi

}

function success_message() {

    echo "######################################"
    echo "You can now unplug the USB cable."
    #echo "Optionally you can mirror your screen with scrcpy."
    echo "######################################"
    echo "Enjoy a smooth wireless experience!"
    echo "######################################"
    echo ""

}

function print_connections() {

    #adb devices -l #print attached devices (both USB and wifi/tcp are connected now)

    socket=$(adb devices -l | grep -w device | grep ${port} | awk '{print $1}')
    #echo "socket: ${socket}"

    #echo "ADB TCP Connections:"

    while [[ -z "${connections}" ]]; do

        connections=$(adb -s "${socket}" shell "netstat -tupna | grep ${port}" 2>/dev/null) #optionally, show that adbd daemon is listening, and the established connection

        exitCode=$?

        if [[ ${exitCode} == 0 ]]; then
            connectionState=1
        else
            connectionState=0
        fi

        if [[ ${connectionState} && ! -z "${connections}" ]]; then
            #echo "${connections}" #print wlan0 ip
            break
        fi

        sleep 1

    done

}

function mirror() {

    scrcpy -s "${socket}" --stay-awake --turn-screen-off -m 2160 --render-driver=opengl --max-fps 60 --bit-rate 6M &
    >/dev/null #mirror android screen via wifi, assuming that scrcpy is already installed or added to PATH ; modify custom options as desired

    #scrcpy-noconsole -s "${socket}" --stay-awake --turn-screen-off -m 2160 --render-driver=opengl --max-fps 60 --bit-rate 6M & > /dev/null #mirror android screen via wifi, assuming that scrcpy is already installed or added to PATH ; modify custom options as desired ; this is for cygwin

}

######################################################################################################################

#MAIN

clear

DIRECTORY=$(cd $(dirname "$(readlink -f "$0")") && pwd)
#echo "Running script from $DIRECTORY"

last_working_device="$DIRECTORY/last_working_device.conf"
touch "${last_working_device}"

#CASES
#usb	wifi
#0      0
#1	    0
#0	    1
#1	    1

#check adb presence on host
type adb >/dev/null
if [[ $? != 0 ]]; then
    echo "Please install adb or add it to system PATH if downloaded as standalone binary"
    exit 1
fi

#try wifi connection first
echo "Attempting Wi-Fi connection first.."
socket=$(adb devices -l | grep ${port} | awk '{print $1}') #try to get attached device wlan0 ip

if [[ -z ${socket} ]]; then
    echo "No WiFi devices detected"
    socket="null" #set to null so that adb connect fails
fi
echo "socket: ${socket}"
echo ""

echo "Trying connection wirelessy via ADB. Please wait..."
adb disconnect >/dev/null #upon reboot, sometimes even if connected, shell will give "error: closed" on first attempt, but on second will work. Need to disconnect and reconnect to make sure the connection is ok
#adb kill-server
status=$(adb connect ${socket})
#adb returns exit code 0 even if it cannot connect. not reliable...

if [[ ${status} == *cannot* ]]; then
    echo "Could not connect via ADB to any detected WiFi device"
    connected="0"

    echo ""
    echo "Trying last known working device.."

    if [[ -s ${last_working_device} ]]; then

        last_working_IP=$(cat ${last_working_device} | grep -E -o "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){1,3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)")
        #echo "Last known working IP: ${last_working_IP}"

        last_Working_port=$(cat ${last_working_device} | grep ${last_working_IP} | awk -F [:] '{print $2}')
        #echo "Last known working port: ${last_Working_port}"

        last_working_socket="${last_working_IP}:${last_Working_port}"

        if [[ ${last_working_socket} != ${socket} ]]; then

            socket="${last_working_socket}"
            echo "Last known working socket: ${socket}"

            status=$(adb connect ${socket})
            if [[ ${status} == *cannot* ]]; then
                echo "Could not connect via ADB to last known WiFi device"
                echo ""
                connected="0"
            else
                echo "Connected via ADB to last known WiFi device:"
                cat "${last_working_device}"
                echo ""
                connected="1"
            fi

        else
            echo "Skipping verifying connection with last known working device as it is the same as the one reported as ADB attached device.."

        fi

    else
        echo "There is no last known working device."

    fi

else
    echo "Connected via adb to WiFi device"
    echo ""
    connected="1"
fi

#0 if failed ; 1 if connected
#echo "connected: ${connected}"
#echo "socket: ${socket}"

#EXAMPLE ERRORS:
#cannot connect to <wlan0_IP>:5555: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond. (10060)
#cannot resolve host 'null' and port 5555: No such host is known. (11001)

if [[ ${connected} == 1 && ! -z "${socket}" && ${socket} != "null" ]]; then #(device is already attached via (tcp/wifi)). Case (wifi 1 ; usb 0) OR (wifi 1 ; usb 1)
    #WARNING! there is a bug that after being disconnected, still appears in devices list

    #echo "connected: ${connected}"
    #echo "socket: ${socket}"

    device=${socket}

    #check if device is rooted
    check_root ${device}

    #if device is not rooted
    if [[ ${rooted} == 0 ]]; then

        echo "Device not rooted. Will skip setting permanent props to allow WiFi connectivity through ADB unnatended"
        echo ""

        set_last_working_device_info
        print_connections
        mirror
        success_message
        sleep 3                #wait for scrcpy to start mirroring
        adb -s ${socket} shell #uncomment to get you straight into android shell (you can comment this line)
        #from here you can 'su -' to drop to root shell
        #exit 0

    else
        #device rooted

        adb -s "${socket}" shell su --command "adbd --version" >/dev/null #try to get adb daemon version on android through wifi only . return "error: closed" in case it cannot run the command
        exitCode="$?"
        #echo "exitCode: ${exitCode}"
        if [[ ${exitCode} == 0 ]]; then #wifi shell command succeded
            #No need to plug USB cable
            #Set props
            adb -s "${socket}" shell su --command "setprop persist.adb.tcp.port ${port}" &&
                echo -n "Property persist.adb.tcp.port was set to:" &&
                adb -s "${socket}" shell su --command "getprop persist.adb.tcp.port" && #set adbd persistent(boot) tcp port
                echo ""

            set_last_working_device_info
            print_connections
            mirror
            success_message
            sleep 3                #wait for scrcpy to start mirroring
            adb -s ${socket} shell #uncomment to get you straight into android shell (you can comment this line)
            #from here you can 'su -' to drop to root shell
            #exit 0

        else #wifi shell command failed for some reason.
            echo "WiFi shell command failed."
            #skip to USB
            usb_connection
            #echo "socket: ${socket}"
            print_connections
            mirror
            success_message
            sleep 3                #wait for scrcpy to start mirroring
            adb -s ${socket} shell #uncomment to get you straight into android shell (you can comment this line)
            #from here you can 'su -' to drop to root shell
            #exit 0
        fi

    fi

else #cases: (wifi 0 ; usb 0) OR (wifi 0 ; USB 1)
    echo ""
    echo "Wi-Fi seems to be turned off or ADB debugging not enabled on device."
    echo "Could not connect via WiFi, switching to USB mode"
    usb_connection
    #echo "socket: ${socket}"
    print_connections
    mirror
    success_message
    sleep 3                #wait for scrcpy to start mirroring
    adb -s ${socket} shell #uncomment to get you straight into android shell (you can comment this line)
    #from here you can 'su -' to drop to root shell
    #exit 0
fi
