# ea — Flutter Discord Tool

## Files to upload to GitHub

Upload this entire folder as a GitHub repository.

---

## Step 1 — Create GitHub account
1. Go to github.com
2. Sign up for a free account
3. Click + New repository
4. Name it: ea
5. Set to Public
6. Click Create repository

## Step 2 — Upload files
1. Click "uploading an existing file" on the repo page
2. Drag and drop all files from this folder (keep folder structure)
3. Click Commit changes

## Step 3 — Create Codemagic account
1. Go to codemagic.io
2. Sign in with GitHub
3. Click Add application
4. Select your ea repo
5. Choose Flutter as the framework

## Step 4 — Build
1. In Codemagic, go to your ea app
2. Click Start new build
3. Select android-release workflow
4. Wait ~10-15 minutes
5. Download the APK from the artifacts section

## Step 5 — Install on Android
1. Download the APK to your phone
2. Go to Settings > Install unknown apps
3. Allow your browser/files app to install APKs
4. Open the APK and install

---

## Using the app

1. Open ea
2. Go to TOKEN tab
3. Paste your Discord token
4. Set your default Channel ID
5. Tap Save & Connect
6. Go to CHAT tab to see messages and chat
7. Use TOOLS tab for autoreact, autokick, status, streaming, VC
8. Use BEEFER tab for autobeefer and autopaster

## Background
The WS connection stays alive as long as the app is in the foreground or recent apps. 
For true 24/7 background, pair with the Python bot on a VPS.
