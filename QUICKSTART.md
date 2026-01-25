# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Verify Installation

```bash
cd /home/seer/Desktop/musically
flutter doctor
```

Make sure Flutter is properly installed and configured.

### Step 2: Add Audio Files (Required)

The app needs 5 audio files for each hymn. Create these files:

```
assets/audio/amazing_grace/
  ├── soprano.mp3
  ├── alto.mp3
  ├── tenor.mp3
  ├── bass.mp3
  └── instrumental.mp3
```

**Important:** All 5 files must have identical duration!

See [AUDIO_FILES.md](AUDIO_FILES.md) for detailed instructions.

### Step 3: Run the App

```bash
flutter run
```

Select your target device (Android emulator, iOS simulator, or connected device).

## 📱 Testing Without Audio Files

You can test the UI without audio files:

1. Launch the app
2. Browse the hymn list
3. Tap a hymn to view details
4. Toggle between lyrics and notation views
5. Open the player screen
6. Explore the mixer controls

Audio playback will only work once you add the audio files.

## 🎵 Using the App

### Playing a Hymn

1. **Home Screen**: Tap any hymn card
2. **Detail Screen**: Read history, view lyrics/notation
3. **Tap "Play"**: Opens the player
4. **Use Controls**: Play, pause, seek forward/backward
5. **Open Mixer**: Adjust individual voice volumes

### Adjusting Voice Mix

1. In player, tap "Open Voice Mixer"
2. Adjust sliders for each voice part
3. Tap volume icon to mute/unmute
4. Changes apply immediately

### Switching Views

In the hymn detail screen:
- Tap the icon in the top-right corner
- Toggle between lyrics (text) and notation (sheet music)
- Pinch to zoom on notation view

## 🔧 Troubleshooting

### "Audio file not found"
- Add the required audio files to `assets/audio/`
- Check that file names match exactly
- Verify paths in `lib/services/hymn_repository.dart`

### App won't build
```bash
flutter clean
flutter pub get
flutter run
```

### Tracks out of sync
- Ensure all audio files have identical duration
- Re-export from your DAW with same settings

## 📚 Documentation

- [README.md](README.md) - Full documentation
- [AUDIO_FILES.md](AUDIO_FILES.md) - Audio file requirements
- [walkthrough.md](.gemini/antigravity/brain/0c967938-3559-48eb-84c5-8f58aa19762c/walkthrough.md) - Implementation details

## 🎯 Next Steps

1. **Add Audio Files**: Follow instructions in AUDIO_FILES.md
2. **Test Playback**: Verify all tracks play in sync
3. **Customize**: Add more hymns to the repository
4. **Build**: Create release builds for distribution

## 💡 Tips

- Use high-quality audio files (128kbps or higher)
- Keep all tracks for a hymn at the same duration
- Test on both mobile and tablet for responsive layout
- Try both light and dark themes

---

**Need Help?** Check the README.md for detailed information or review the code comments in the source files.
