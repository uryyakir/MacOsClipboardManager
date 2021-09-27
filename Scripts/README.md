# HOWTO: Create a keyboard shortcut to open / close the Clipboard Manager
## simply follow the following steps:
<ol>
  <li>Copy the `applescript workflow` to your local 'Services' folder using the following Terminal command:
    
  `cp -r Scripts/OpenClipboardManagerShortcut.workflow ~/Library/Services/OpenClipboardManagerShortcut.workflow`
  </li>
  <li>
    Go to `System Preferences -> Keyboard -> Shortcuts`. Under General, you should see a service named `OpenClipboardManagerShortcut`. 
    Add your custom keyboard shortcut to run the service.
  </li>
  <li>
    Open `System Preferences -> Security & Privacy -> Privacy`. Choose `Accessibility` from the side-menu.<br>
    Add `Automator` to the permitted app list.
  </li>
</ol>

#### NOTE: when attempting to use your keyboard shortcut from some apps (e.g. Google Chrome), you might encounter a permissions error.
#### The error should say something along the lines of:
`The action "Run AppleScript" encountered an error: ... is not allowed assistive access." `
#### If you see that error, all you need to do is to add said application to the `Accessibility` list, similiar to what we've done for `Automator`.

## ENJOY!
