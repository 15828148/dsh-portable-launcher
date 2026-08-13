DeepSeek Harness Web UI - Portable Launcher
===========================================

[What's inside]
  dsh-web.bat   One-click launcher (core)
  setup.bat     Creates a desktop shortcut with icon - run once
  deepseek.ico  Icon file

[How to use]
  Step 1: Double-click dsh-web.bat (or "DSH Web UI" on your desktop)
          - If Node.js is missing, you'll be asked to download a
            portable Node.js (press Y; no admin required, it is
            added to your user PATH automatically)
          - If Node.js is already installed, this step is skipped

  Step 2: Put the whole folder anywhere (e.g. D:\ or Desktop) and run
          setup.bat once - a desktop shortcut "DSH Web UI" appears.
          (If you move the folder later, run setup.bat again)

  Step 3: Double-click "DSH Web UI" to start
          - First run downloads components; it takes a few minutes,
            please be patient
          - If the download is slow or fails, the window asks whether
            to retry with the China npm mirror - press R
          - The browser opens http://127.0.0.1:3080 automatically

  Step 4: First time? Add your own API key in Settings in the UI
          (Get one at https://platform.deepseek.com)

[FAQ]
  - Blue "Windows protected your PC" prompt when starting the .bat?
    Click "More info" -> "Run anyway". This is normal for files
    downloaded from the internet.
  - ZIP from WeChat won't open or fails to extract?
    Ask the sender to resend it using the desktop WeChat app
    (mobile WeChat occasionally corrupts files).
  - Asked "Download portable Node.js?" - only when Node.js is
    missing; press Y to auto-install.
  - The window shows 3 major stages:
    [1/3] Node.js check -> [2/3] dsh package check -> [3/3] launch.
    Downloads/installs appear as indented minor steps. When
    everything is ready it launches directly with zero downloads.
  - A step failed? You'll be asked to retry (up to 3 times). After 3
    failed retries, concrete manual steps are shown - follow them.
  - Closed the black window mid-setup? Run it again - it resumes
    (look for [Resume] hints) instead of starting over. Files that
    are already downloaded are never re-downloaded.
  - "This folder is not writable"? Move the whole folder somewhere
    normal (e.g. D:\ or Desktop). Protected folders like Program
    Files cannot be used.
  - First run is slow (download + system scan); later starts take
    only a few seconds.
  - "Port already in use"? dsh is already running - just open
    http://127.0.0.1:3080 in your browser.
  - Closing the window stops the service.

[Notes]
  - This package contains NO API key - please use your own.
  - Conversations and settings are stored in %USERPROFILE%\.dsh
    and persist across restarts.
