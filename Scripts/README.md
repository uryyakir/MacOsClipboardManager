# HOWTO: Create a keyboard shortcut to open / close the Clipboard Manager
## simply follow the following steps:

1. Download the Scripts folder from this repository to your device. I recommend using this [tool](https://github.com/uryyakir/MacOsClipboardManager/tree/main/Scripts) with the folder's URL (https://github.com/uryyakir/MacOsClipboardManager/tree/main/Scripts)

2. Go the parent folder containing the downloaded "Scripts" folder, and copy the `applescript workflow` file to your local 'Services' folder using the following Terminal command:    
  `cp -r Scripts/OpenClipboardManagerShortcut.workflow ~/Library/Services/OpenClipboardManagerShortcut.workflow`
  
3. Go to `System Preferences -> Keyboard -> Shortcuts -> Services`. Under General, you should see a service named `OpenClipboardManagerShortcut`. 
Add your custom keyboard shortcut to run the service.
  
4. Open `System Preferences -> Security & Privacy -> Privacy`. Choose `Accessibility` from the side-menu.<br>
Add `Automator.app` to the permitted app list.

#### NOTE: when attempting to use your keyboard shortcut from some apps (e.g. Google Chrome), you might encounter a permissions error.
#### The error should say something along the lines of:
`The action "Run AppleScript" encountered an error: ... is not allowed assistive access." `
#### If you see that error, all you need to do is to add said application to the `Accessibility` list, similiar to what we've done for `Automator`.

## ENJOY!
