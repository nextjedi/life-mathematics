# Play Store Screenshots Guide

## Requirements
- Minimum: 2 screenshots
- Recommended format: PNG or JPEG
- Recommended size: 1080 x 1920 pixels (9:16 ratio) for phone screenshots
- Maximum file size: 8MB per screenshot

## Screenshot 1: Light Mode - Basic Calculation

**What to show:**
1. Open the app in LIGHT mode
2. Perform a simple calculation like: 123 + 456 = 579
3. Make sure the result is showing on the display
4. The interface should look clean and bright

**How to capture:**
1. Run: `flutter run` on your Android device
2. If in dark mode, tap the moon/sun icon to switch to light mode
3. Enter: 123 + 456 =
4. Take screenshot (Volume Down + Power button on most Android devices)

**What this shows:** Clean interface, light theme, basic calculator functionality

---

## Screenshot 2: Dark Mode - Active Calculation

**What to show:**
1. Switch to DARK mode
2. Perform a calculation like: 789 × 12 = 9468
3. Show the result displayed
4. Demonstrates the dark theme and larger numbers

**How to capture:**
1. Tap the sun icon to switch to dark mode
2. Tap C to clear
3. Enter: 789 × 12 =
4. Take screenshot

**What this shows:** Beautiful dark theme, night-time usability, larger calculations

---

## Where to find screenshots on Android

After taking screenshots, find them in:
- Photos app → Screenshots folder
- Or: Internal Storage/Pictures/Screenshots/

## Where to upload

1. Go to Google Play Console
2. Your app → Store presence → Main store listing
3. Scroll to "Phone screenshots"
4. Click "Add screenshots" and upload both images

---

## Optional: Better Screenshots with Frames

For more professional-looking screenshots, you can:

1. Use online tools like:
   - https://screenshots.pro/
   - https://mockuphone.com/
   - https://device-shots.com/

2. These tools add device frames around your screenshots
3. Upload your raw screenshots and download with frames
4. Use the framed versions for Play Store

---

## Quick Command to Take Screenshots

Run these commands after opening the app:

```bash
# If using emulator or connected device
adb shell screencap -p /sdcard/screenshot1.png
adb pull /sdcard/screenshot1.png
```

Or just use the physical buttons on your Android device!
