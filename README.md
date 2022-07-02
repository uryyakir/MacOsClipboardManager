# Clipy - Clipboard Manager Application

Clipy is a MacOS application that seamlessly manages your clipboard. Running unnoticeably from your menu-bar, this app stores all data (both text and media) that you copy, allowing you to quickly find that week-old snippet of text you've been looking for.

## Current Features
* Supporting both textual content and media.
* All of your copied data is searchable.
* You may select multiple items and "push" them to your clipboard simultaneously. When pasted, those items will appear together, separated by a newline.
* When hovering a cell in the app's table, a popover will open and present the entire text. This feature is also useful for copied images (that are very small by default in the app's UI).
* Supports easy-to-use keyboard navigation - you can use this app without touching your mouse and without interrupting your workflow.

## Privacy
This app uses *local & persistent storage* for your clipboard history. Your private information is not sent anywhere and is only accessible by you!

## Installation

The `.pkg` file is currently available in my [dropbox](https://www.dropbox.com/sh/dhs0t40ypk3sbnx/AACQfR1bdTintY6Gdk-fnIExa?dl=0).
To install the application:

1. Download the `.pkg` file from the provided link. By default it should be downloaded to your `Downloads` folder.
2. Navigate to your `Downloads` folder.
3. Right-click the `Clipboard-Manager.pkg` file, click `Open`.
4. You should receive some warning about opening a file from an untrusted developer. Ignore that and move on with the installation.
5. Go through the installer, it should be pretty straight-forward.
6. After the installation is complete, you should be able to launch the `Clipboard Manager` application by pressing ⌘+Space and searching for it.
7. After you launch the application, don't expect a window to open. This is a menu-bar application :)<br>
Instead, you should see the app's icon in your tool-bar at the top of your screen:
<br>![app icon](Clipboard-Manager/Assets.xcassets/clipboard-icon-white.imageset/Webp.net-resizeimage.png)
8. To set a keyboard shortcut for opening / closing the application, please follow the instruction [here](https://github.com/uryyakir/MacOsClipboardManager/tree/main/Scripts).

I'm working on getting the application on the Appstore, keep an eye out for that!

## Usage
Using this application is super easy and intuative. All you have to do is click the small icon in the menu-bar and start navigating. You can navigate using either your mouse or the keyboard.

Note that you may select multiple items using the `Shift + Up/Down` keys on the keyboard, or `⌘ + left click` when using the mouse.

When you type anything on your keyboard, that text is injected automatically into the search field, filtering your clipboard history and showing you the relevant results.

To exit the app, you may either click outside of its UI, press the `Esc` button or click the red `X` in the top left. To kill the application, you may either press `⌘+Q` or use the button at the bottom of the application.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Screenshots
![overview](Clipboard-Manager/Appstore%20Assets/Screenshots/cropped/overview.png)
![popover preview](Clipboard-Manager/Appstore%20Assets/Screenshots/cropped/popover%20preview.png)
![text search](Clipboard-Manager/Appstore%20Assets/Screenshots/cropped/text%20search.png)
![multiple item selection](Clipboard-Manager/Appstore%20Assets/Screenshots/cropped/multiple%20item%20selection.png)
![image preview](Clipboard-Manager/Appstore%20Assets/Screenshots/cropped/image%20preview.png)
