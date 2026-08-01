# Enable ADB on Your Device

## Enable ADB

Please refer to [Google's documentation](https://developer.android.com/studio/debug/dev-options#enable) for instructions on enabling ADB on your device.

Check the section titled `Enable USB Debugging on Your Device`. You must enable this feature on your device to access it from your computer.

## Grant Access

Typically, when a device is connected to a computer, a dialog box will automatically pop up asking whether to allow the connection, as shown in the image below. If this dialog box does not appear, it may have been previously denied. For most devices, disconnecting and reconnecting the device to the computer will prompt the authorization dialog again.

- Some devices may require you to enter a password. Please follow the on-screen instructions on your device.

![Authorization Prompt](../../res/S41212-14134708_com.android.systemui.jpeg)

At this point, it is recommended to check `Always allow debugging from this computer` on your device and then tap `OK`. Subsequently, click `Scan` on the left side of the Axchange software on your computer to refresh the device status. You can also find this option in the `Device` tab in the menu bar.

- For stability reasons, Axchange **does not** automatically refresh the device status.

![Screenshot After Refreshing](../../res/SCR-20241212-mrvf.jpeg)

## Denied Access

If the computer running Axchange is not trusted by the device, an access denied prompt will appear, as shown below.

![Access Denied Prompt](../../res/SCR-20241212-mrqa.jpeg)

## Technical Information

**Axchange is compatible with the system-installed ADB.**

If port `5037` is already occupied by another program when Axchange starts and responds to ADB queries, the bundled ADB service within the application will not start. Otherwise, it will attempt to start the ADB service on port `5037`.

As a result, Axchange stores authorization information in different locations depending on the ADB service.

For the bundled ADB service within the application, your authorization information will be stored within the application's container at the following locations:

```
~/Library/Containers/wiki.qaq.Axchange/Data/.android/adbkey
~/Library/Containers/wiki.qaq.Axchange/Data/.android/adbkey.pub
```

For other ADB services available on your computer, your authorization information will typically be stored in the home directory corresponding to that ADB service:

```
~/.android/adbkey
~/.android/adbkey.pub
```

**Regardless of the situation, authorization must be granted on the device to access it.**
