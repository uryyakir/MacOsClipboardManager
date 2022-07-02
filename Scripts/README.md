# HOWTO: Create a keyboard shortcut to open / close the Clipboard Manager

## simply follow the following steps:

  1. Clone the repo.
  2. Copy the applescript file to your local `Scripts` folder, i.e.: `cp Scripts/openClipboardManagerAppleScript.scpt ~/Library/Scripts/`.
  3. Download the open source shortcut manager [iCanHazShortcut](https://github.com/deseven/icanhazshortcut): `brew install icanhazshortcut`.
  4. Open the *iCanHazshortcut* application.
  5. Create a new shortcut:
		* Set the short command to run the applescript: `osascript ~/Library/Scripts/openClipboardManagerAppleScript.scpt`.
		* Set whatever keyboard shortcut that works for you.
6. Profit???


__NOTE__: when attempting to test your keyboard shortcut, you might encounter a permissions error.
If you see that error, all you need to do is to permit the *iCanHazShortcut* to control your computer: System Preferences --> Security & Privacy --> Accessibility --> Mark the checkbox next to the *iCanHazShortcut* application.

## ENJOY!
