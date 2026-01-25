# Audio Files Required

This app requires 5 separate audio files for each hymn to function properly.

## Required Files

Place your audio files in the following structure:

```
assets/audio/
├── amazing_grace/
│   ├── soprano.mp3
│   ├── alto.mp3
│   ├── tenor.mp3
│   ├── bass.mp3
│   └── instrumental.mp3
├── how_great_thou_art/
│   ├── soprano.mp3
│   ├── alto.mp3
│   ├── tenor.mp3
│   ├── bass.mp3
│   └── instrumental.mp3
└── holy_holy_holy/
    ├── soprano.mp3
    ├── alto.mp3
    ├── tenor.mp3
    ├── bass.mp3
    └── instrumental.mp3
```

## Audio File Specifications

### Format
- **Supported formats**: MP3, M4A, WAV, OGG
- **Recommended**: MP3 (best compatibility)
- **Bitrate**: 128kbps or higher for quality

### Critical Requirements

1. **Identical Duration**: All 5 tracks for a single hymn MUST have the exact same duration
   - Example: If soprano.mp3 is 2:30.000, all other tracks must also be 2:30.000
   - Even 100ms difference will cause sync issues

2. **Pre-synchronized**: Tracks should be synchronized at the source
   - Export all tracks from the same DAW project
   - Use the same start/end points for all tracks
   - Ensure no silence padding differences

3. **Same Sample Rate**: All tracks should have the same sample rate
   - Recommended: 44.1kHz or 48kHz

## How to Create Audio Files

### Option 1: Using a DAW (Digital Audio Workstation)

1. **Record or import** your hymn with all voice parts
2. **Separate each voice** into individual tracks
3. **Export each track** separately:
   - Solo the Soprano track → Export as `soprano.mp3`
   - Solo the Alto track → Export as `alto.mp3`
   - Solo the Tenor track → Export as `tenor.mp3`
   - Solo the Bass track → Export as `bass.mp3`
   - Solo all instrumental tracks → Export as `instrumental.mp3`
4. **Verify** all files have identical duration

### Option 2: Using MIDI Files

1. Find or create a MIDI file of the hymn
2. Load into a DAW or notation software
3. Assign different instruments to each voice part
4. Export each track separately as audio

### Option 3: Recording Live

1. Record each voice part separately
2. Use a metronome/click track for timing
3. Align all recordings in a DAW
4. Export with identical start/end points

## Testing Your Audio Files

Before adding files to the app, verify:

1. **Duration Check**:
   ```bash
   # On Linux/Mac
   ffprobe -i soprano.mp3 -show_entries format=duration -v quiet -of csv="p=0"
   ffprobe -i alto.mp3 -show_entries format=duration -v quiet -of csv="p=0"
   # Compare all durations
   ```

2. **Playback Test**: Play all 5 files simultaneously in a media player to ensure they're in sync

3. **Quality Check**: Listen to each track individually for clarity

## Placeholder Audio (For Testing Only)

If you don't have audio files yet, you can create silent placeholder files:

```bash
# Create 30-second silent MP3 files (requires ffmpeg)
cd assets/audio/amazing_grace
ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 30 -q:a 9 -acodec libmp3lame soprano.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 30 -q:a 9 -acodec libmp3lame alto.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 30 -q:a 9 -acodec libmp3lame tenor.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 30 -q:a 9 -acodec libmp3lame bass.mp3
ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t 30 -q:a 9 -acodec libmp3lame instrumental.mp3
```

**Note**: Silent files are only for testing the app structure. You won't hear any audio.

## Resources

### Free Hymn MIDI Files
- [HymnSite.com](http://www.hymnsite.com/midi/)
- [Cyberhymnal](http://www.cyberhymnal.org/)

### DAW Software (Free Options)
- **Audacity** (Free, cross-platform)
- **GarageBand** (Free, Mac only)
- **Reaper** (Free trial, all platforms)
- **Ardour** (Free, open-source)

### Online Resources
- **MuseScore**: Create and export individual voice parts
- **Flat.io**: Online music notation with MIDI export

## Troubleshooting

### "Audio file not found" error
- Check file paths in `lib/services/hymn_repository.dart`
- Ensure files are in the correct directories
- Verify file names match exactly (case-sensitive)

### Tracks are out of sync
- Check that all files have identical duration
- Re-export from DAW with same settings
- Use audio editing software to trim to exact same length

### Poor audio quality
- Increase bitrate when exporting (192kbps or higher)
- Use lossless format (WAV) then convert to MP3
- Check source recordings for quality issues

---

**Remember**: The app's synchronization feature only works if you provide properly synchronized audio files. The app maintains sync during playback but cannot create sync from misaligned files.
