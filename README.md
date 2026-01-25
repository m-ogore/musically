# Musically - Multi-Track Hymn Practice App

A high-performance Flutter application for practicing hymns with individual voice part control, synchronized multi-track audio playback, and responsive design for mobile and tablet devices.

## Features

### 🎵 Multi-Track Audio Synchronization
- Play 5 separate audio tracks simultaneously (Soprano, Alto, Tenor, Bass, Instrumental)
- Automatic drift detection and correction (50ms tolerance)
- Synchronized playback across all tracks

### 🎚️ Voice Mixer
- Individual volume control for each voice part
- Mute/unmute toggles for each track
- Color-coded UI for easy identification
- Real-time volume adjustments

### 📱 Responsive Design
- **Mobile**: ListView layout for easy scrolling
- **Tablet**: GridView layout with 2-3 columns
- Adaptive UI components for different screen sizes

### 📖 Dual View Modes
- **Lyrics View**: Scrollable, selectable text display
- **Notation View**: Interactive sheet music with zoom and pan
- Easy toggle between views

### 🎨 Modern UI
- Material 3 design
- Light and dark theme support
- Smooth animations and transitions

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── hymn.dart                      # Hymn data model
│   ├── audio_track.dart               # Audio track model
│   └── mixer_state.dart               # Mixer state management
├── services/
│   ├── audio_player_service.dart      # Multi-track audio engine
│   └── hymn_repository.dart           # Hymn data repository
├── providers/
│   ├── hymn_provider.dart             # Hymn state provider
│   └── player_provider.dart           # Player state provider
├── screens/
│   ├── home_screen.dart               # Home screen with hymn list
│   ├── hymn_detail_screen.dart        # Hymn details and history
│   └── player_screen.dart             # Full-screen player
├── widgets/
│   ├── hymn_card.dart                 # Hymn card component
│   ├── mixer_bottom_sheet.dart        # Mixer controls
│   ├── lyrics_view.dart               # Lyrics display
│   ├── notation_view.dart             # Musical notation display
│   └── player_controls.dart           # Playback controls
└── utils/
    └── constants.dart                 # App constants
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10.3 or higher
- Dart 3.10.3 or higher

### Installation

1. Clone the repository:
```bash
cd /home/seer/Desktop/musically
```

2. Install dependencies:
```bash
flutter pub get
```

3. **IMPORTANT: Add Audio Files**

The app requires 5 separate audio files for each hymn. You need to provide these files:

For each hymn, create the following audio files:
```
assets/audio/amazing_grace/
  ├── soprano.mp3
  ├── alto.mp3
  ├── tenor.mp3
  ├── bass.mp3
  └── instrumental.mp3

assets/audio/how_great_thou_art/
  ├── soprano.mp3
  ├── alto.mp3
  ├── tenor.mp3
  ├── bass.mp3
  └── instrumental.mp3

assets/audio/holy_holy_holy/
  ├── soprano.mp3
  ├── alto.mp3
  ├── tenor.mp3
  ├── bass.mp3
  └── instrumental.mp3
```

**Audio File Requirements:**
- Format: MP3, M4A, or WAV
- All 5 tracks for a hymn must have **identical duration**
- Tracks should be pre-synchronized at the source
- Recommended: High-quality recordings (128kbps or higher)

**Where to get audio files:**
- Record separate voice parts using a DAW (Digital Audio Workstation)
- Use MIDI files and export each track separately
- Commission recordings from a choir or musicians
- Use royalty-free hymn recordings (ensure you have separate tracks)

4. Run the app:
```bash
flutter run
```

## Technical Details

### Audio Synchronization Algorithm

The app uses a sophisticated synchronization system:

1. **Initialization**: All 5 audio players load their respective files
2. **Synchronized Start**: All players start within the same event loop tick
3. **Drift Monitoring**: Primary player (Soprano) position is monitored every 100ms
4. **Drift Correction**: If any player drifts >50ms, all players pause, seek, and resume

### State Management

- **Provider** pattern for reactive state updates
- **HymnProvider**: Manages hymn data and view mode
- **PlayerProvider**: Manages playback state and mixer settings

### Dependencies

- `just_audio`: Audio playback engine
- `audio_session`: Audio session management
- `provider`: State management
- `flutter_svg`: SVG rendering
- `responsive_builder`: Responsive layout utilities

## Usage

### Playing a Hymn

1. Launch the app to see the list of available hymns
2. Tap on a hymn card to view details
3. Toggle between lyrics and notation using the button in the app bar
4. Tap the "Play" button to open the player
5. Use playback controls to play, pause, or seek
6. Tap "Open Voice Mixer" to adjust individual track volumes

### Adjusting Voice Mix

1. In the player screen, tap "Open Voice Mixer"
2. Adjust the slider for each voice part
3. Tap the volume icon to mute/unmute a track
4. Changes apply immediately to playback

### Responsive Layouts

- **Mobile** (< 600px width): Single column list
- **Tablet** (600-900px): 2-column grid
- **Desktop** (> 900px): 3-column grid

## Adding New Hymns

To add a new hymn, edit `lib/services/hymn_repository.dart`:

```dart
Hymn(
  id: '4',
  title: 'Your Hymn Title',
  author: 'Composer Name',
  history: 'Historical background...',
  lyrics: '''
Verse 1:
Your lyrics here...
  ''',
  notationUrl: 'assets/notation/your_hymn.png',
  audioPaths: {
    'soprano': 'assets/audio/your_hymn/soprano.mp3',
    'alto': 'assets/audio/your_hymn/alto.mp3',
    'tenor': 'assets/audio/your_hymn/tenor.mp3',
    'bass': 'assets/audio/your_hymn/bass.mp3',
    'instrumental': 'assets/audio/your_hymn/instrumental.mp3',
  },
),
```

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Known Limitations

1. **Audio Files Required**: The app cannot function without the 5 separate audio files for each hymn
2. **Local Storage**: Audio files are stored locally, which increases app size
3. **Sync Accuracy**: Synchronization depends on audio file quality and device performance

## Future Enhancements

- [ ] Cloud storage for audio files (Firebase Storage, CDN)
- [ ] Download hymns on-demand to reduce app size
- [ ] Auto-scroll lyrics during playback
- [ ] Highlight current verse based on playback position
- [ ] Favorites and playlists
- [ ] Search functionality
- [ ] Custom tempo control
- [ ] Practice mode with looping

## Troubleshooting

### Audio not playing
- Ensure all 5 audio files exist for the hymn
- Check file paths in `hymn_repository.dart`
- Verify audio files are in supported formats (MP3, M4A, WAV)

### Tracks out of sync
- Ensure all audio files have identical duration
- Check that audio files are high quality
- Try on a different device to rule out performance issues

### UI not responsive
- Clear app cache and rebuild
- Check Flutter version compatibility
- Verify all dependencies are up to date

## License

This project is created for educational and worship purposes.

## Credits

- **Flutter Team**: For the amazing framework
- **just_audio**: For the audio playback engine
- **Sample Hymns**: Amazing Grace, How Great Thou Art, Holy Holy Holy

---

**Note**: This app is a demonstration of multi-track audio synchronization. To use it fully, you must provide your own audio recordings for each voice part.