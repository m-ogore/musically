import '../models/hymn.dart';

/// Repository for managing hymn data
/// In a production app, this would fetch from a database or API
class HymnRepository {
  /// Gets all available hymns
  Future<List<Hymn>> getAllHymns() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _generateAllHymns();
  }

  /// Gets a hymn by its ID
  Future<Hymn?> getHymnById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final allHymns = _generateAllHymns();
    try {
      return allHymns.firstWhere((hymn) => hymn.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Generates the full list of hymns
  List<Hymn> _generateAllHymns() {
    final List<Hymn> hymns = [];
    final specialHymns = {
      '1': _sampleHymns[0], // Praise to the Lord
      '2': _sampleHymns[1], // All Creatures of Our God and King
      '3': _sampleHymns[2], // God Himself Is With Us
      // Keeping existing samples as bonus or removing if replaced?
      // User specifically asked for 1, 2, 3 to be full.
      // I will keep the others as available if they don't conflict, 
      // but re-index sample hymns to match 1, 2, 3.
    };

    // Standard SDA Hymnal has 695 hymns
    for (int i = 1; i <= 695; i++) {
      final id = i.toString();
      if (specialHymns.containsKey(id)) {
        hymns.add(specialHymns[id]!);
      } else {
        hymns.add(_createPlaceholderHymn(id));
      }
    }
    return hymns;
  }

  // ... _createPlaceholderHymn ...

  /// Sample hymns with full data
  static final List<Hymn> _sampleHymns = [
    Hymn(
      id: '1',
      title: 'Praise to the Lord',
      author: 'Joachim Neander',
      history: 'Written by Joachim Neander in 1680. Theme of praise and adoration.',
      lyrics: '''
Verse 1:
Praise to the Lord, the Almighty, the King of creation!
O my soul, praise Him, for He is thy health and salvation!
All ye who hear, now to His temple draw near;
Join me in glad adoration!

Verse 2:
Praise to the Lord, who o'er all things so wondrously reigneth,
Shelters thee under His wings, yea, so gently sustaineth!
Hast thou not seen how thy desires e'er have been
Granted in what He ordaineth?

Verse 3:
Praise to the Lord, who doth prosper thy work and defend thee;
Surely His goodness and mercy here daily attend thee.
Ponder anew what the Almighty can do,
If with His love He befriend thee.
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "F",
        "timeSignature": "3/4",
        "measures": [
          [
            {"note": "F4", "duration": "quarter"},
            {"note": "F4", "duration": "quarter"},
            {"note": "C5", "duration": "quarter"}
          ],
          [
            {"note": "A4", "duration": "quarter"},
            {"note": "F4", "duration": "quarter"},
            {"note": "E4", "duration": "quarter"}
          ],
          [
            {"note": "D4", "duration": "quarter"},
            {"note": "C4", "duration": "half"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 2000),
        const Duration(milliseconds: 3000),
        const Duration(milliseconds: 4000),
        const Duration(milliseconds: 5000),
        const Duration(milliseconds: 6000),
        const Duration(milliseconds: 7000),
      ],
      audioPaths: {
        'soprano': 'assets/audio/1/soprano.mp3',
        'alto': 'assets/audio/1/alto.mp3',
        'tenor': 'assets/audio/1/tenor.mp3',
        'bass': 'assets/audio/1/bass.mp3',
        'instrumental': 'assets/audio/1/instrumental.mp3',
      },
    ),
    Hymn(
      id: '2',
      title: 'All Creatures of Our God and King',
      author: 'St. Francis of Assisi',
      history: 'Based on Canticle of the Sun by St. Francis of Assisi (1225). Tune: Lasst uns erfreuen.',
      lyrics: '''
Verse 1:
All creatures of our God and King,
Lift up your voice and with us sing,
Alleluia! Alleluia!
Thou burning sun with golden beam,
Thou silver moon with softer gleam!

Refrain:
O praise Him! O praise Him!
Alleluia! Alleluia! Alleluia!

Verse 2:
Thou rushing wind that art so strong,
Ye clouds that sail in heaven along,
O praise Him! Alleluia!
Thou rising moon, in praise rejoice,
Ye lights of evening, find a voice!
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "D",
        "timeSignature": "3/2",
        "measures": [
          [
            {"note": "D4", "duration": "quarter"},
            {"note": "D4", "duration": "quarter"},
            {"note": "E4", "duration": "quarter"},
            {"note": "F#4", "duration": "quarter"}
          ],
          [
            {"note": "G4", "duration": "half"},
            {"note": "F#4", "duration": "half"},
            {"note": "E4", "duration": "half"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 2000),
        const Duration(milliseconds: 3000),
        const Duration(milliseconds: 4000),
        const Duration(milliseconds: 6000),
        const Duration(milliseconds: 8000),
      ],
      audioPaths: {
        'soprano': 'assets/audio/2/soprano.mp3',
        'alto': 'assets/audio/2/alto.mp3',
        'tenor': 'assets/audio/2/tenor.mp3',
        'bass': 'assets/audio/2/bass.mp3',
        'instrumental': 'assets/audio/2/instrumental.mp3',
      },
    ),
    Hymn(
      id: '3',
      title: 'God Himself Is With Us',
      author: 'Gerhard Tersteegen',
      history: 'German hymn from 1729. Tune: Arnsberg.',
      lyrics: '''
Verse 1:
God Himself is with us:
Let us all adore Him,
And with awe appear before Him.
God is here within us;
Soul, in silence fear Him,
Humbly, fervently draw near Him.
Now His own who have known
God, in worship lowly,
Yield their spirits wholly.

Verse 2:
Come, abide within me;
Let my soul, like Mary,
Be Thine earthly sanctuary.
Come, indwelling Spirit,
With transfigured splendor;
Love and honor will I render.
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "G",
        "timeSignature": "2/2",
        "measures": [
          [
            {"note": "G4", "duration": "quarter"},
            {"note": "G4", "duration": "quarter"},
            {"note": "A4", "duration": "quarter"},
            {"note": "B4", "duration": "quarter"}
          ],
          [
            {"note": "A4", "duration": "half"},
            {"note": "G4", "duration": "half"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 2000),
        const Duration(milliseconds: 3000),
        const Duration(milliseconds: 4000),
        const Duration(milliseconds: 6000),
      ],
      audioPaths: {
        'soprano': 'assets/audio/3/soprano.mp3',
        'alto': 'assets/audio/3/alto.mp3',
        'tenor': 'assets/audio/3/tenor.mp3',
        'bass': 'assets/audio/3/bass.mp3',
        'instrumental': 'assets/audio/3/instrumental.mp3',
      },
    ),
  ];
      // ... existing content ...

      author: 'John Newton',
      history: '''
Amazing Grace is a Christian hymn published in 1779, with words written in 1772 by the English poet and Anglican clergyman John Newton (1725–1807).

Newton wrote the words from personal experience. He grew up without any particular religious conviction, but his life's path was formed by a variety of twists and coincidences that were often put into motion by his recalcitrant insubordination. He was pressed into naval service and became a sailor, eventually participating in the slave trade. One night a terrible storm battered his vessel so severely that he became frightened enough to call out to God for mercy, a moment that marked the beginning of his spiritual conversion.
      '''.trim(),
      lyrics: '''
Verse 1:
Amazing grace! How sweet the sound
That saved a wretch like me!
I once was lost, but now am found;
Was blind, but now I see.

Verse 2:
'Twas grace that taught my heart to fear,
And grace my fears relieved;
How precious did that grace appear
The hour I first believed.

Verse 3:
Through many dangers, toils and snares,
I have already come;
'Tis grace hath brought me safe thus far,
And grace will lead me home.

Verse 4:
The Lord has promised good to me,
His Word my hope secures;
He will my Shield and Portion be,
As long as life endures.

Verse 5:
When we've been there ten thousand years,
Bright shining as the sun,
We've no less days to sing God's praise
Than when we'd first begun.
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "G",
        "timeSignature": "3/4",
        "measures": [
          [
            {"note": "D4", "duration": "quarter"}
          ],
          [
            {"note": "G4", "duration": "half"},
            {"note": "B4", "duration": "eighth"},
            {"note": "G4", "duration": "eighth"}
          ],
          [
            {"note": "B4", "duration": "half"},
            {"note": "A4", "duration": "quarter"}
          ],
          [
            {"note": "G4", "duration": "half"},
            {"note": "E4", "duration": "quarter"}
          ],
          [
            {"note": "D4", "duration": "half"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),    // D4 (pickup)
        const Duration(milliseconds: 1000), // G4
        const Duration(milliseconds: 3000), // B4
        const Duration(milliseconds: 3500), // G4
        const Duration(milliseconds: 4000), // B4
        const Duration(milliseconds: 6000), // A4
        const Duration(milliseconds: 7000), // G4
        const Duration(milliseconds: 9000), // E4
        const Duration(milliseconds: 10000),// D4
      ],
      audioPaths: {
        'soprano': 'assets/audio/amazing_grace/soprano.mp3',
        'alto': 'assets/audio/amazing_grace/alto.mp3',
        'tenor': 'assets/audio/amazing_grace/tenor.mp3',
        'bass': 'assets/audio/amazing_grace/bass.mp3',
        'instrumental': 'assets/audio/amazing_grace/instrumental.mp3',
      },
    ),
    Hymn(
      id: '86',
      title: 'How Great Thou Art',
      author: 'Carl Boberg',
      history: '''
"How Great Thou Art" is a Christian hymn based on a Swedish traditional melody and a poem written by Carl Boberg (1859–1940) in Mönsterås, Sweden, in 1885.

It was translated into German and then into Russian. It was translated into English from the Russian by English missionary Stuart K. Hine, who also added two original verses of his own. The composition was set to a Swedish folk melody. It was voted the United Kingdom's favorite hymn by BBC's Songs of Praise.
      '''.trim(),
      lyrics: '''
Verse 1:
O Lord my God, when I in awesome wonder
Consider all the worlds Thy hands have made,
I see the stars, I hear the rolling thunder,
Thy power throughout the universe displayed!

Chorus:
Then sings my soul, my Savior God, to Thee:
How great Thou art! How great Thou art!
Then sings my soul, my Savior God, to Thee:
How great Thou art! How great Thou art!
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "C",
        "timeSignature": "4/4",
        "measures": [
          [
            {"note": "G4", "duration": "quarter"},
            {"note": "C5", "duration": "quarter"},
            {"note": "C5", "duration": "quarter"},
            {"note": "G4", "duration": "quarter"}
          ],
          [
            {"note": "A4", "duration": "quarter"},
            {"note": "A4", "duration": "half"},
            {"note": "G4", "duration": "quarter"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 2000),
        const Duration(milliseconds: 3000),
        const Duration(milliseconds: 4000),
        const Duration(milliseconds: 5000),
        const Duration(milliseconds: 7000),
      ],
      audioPaths: {
        'soprano': 'assets/audio/how_great_thou_art/soprano.mp3',
        'alto': 'assets/audio/how_great_thou_art/alto.mp3',
        'tenor': 'assets/audio/how_great_thou_art/tenor.mp3',
        'bass': 'assets/audio/how_great_thou_art/bass.mp3',
        'instrumental': 'assets/audio/how_great_thou_art/instrumental.mp3',
      },
    ),
    Hymn(
      id: '73',
      title: 'Holy, Holy, Holy',
      author: 'Reginald Heber',
      history: '''
"Holy, Holy, Holy! Lord God Almighty!" is a Christian hymn written by Reginald Heber (1783–1826). Heber wrote the hymn in 1826 for use on Trinity Sunday. It is one of the most popular hymns in the English language.

The hymn is a celebration of the Trinity and is based on Revelation 4:8-11. The tune, called "Nicaea," was composed by John Bacchus Dykes in 1861 specifically for this hymn. The hymn has been translated into many languages and is sung in churches around the world.
      '''.trim(),
      lyrics: '''
Verse 1:
Holy, holy, holy! Lord God Almighty!
Early in the morning our song shall rise to Thee;
Holy, holy, holy! Merciful and mighty!
God in three Persons, blessèd Trinity!
      '''.trim(),
      notationData: '''
      {
        "clef": "treble",
        "keySignature": "D",
        "timeSignature": "4/4",
        "measures": [
          [
            {"note": "D4", "duration": "quarter"},
            {"note": "D4", "duration": "quarter"},
            {"note": "F#4", "duration": "quarter"},
            {"note": "F#4", "duration": "quarter"}
          ],
          [
            {"note": "A4", "duration": "quarter"},
            {"note": "A4", "duration": "quarter"},
            {"note": "A4", "duration": "half"}
          ]
        ]
      }
      ''',
      noteTimestamps: [
        const Duration(milliseconds: 0),
        const Duration(milliseconds: 1000),
        const Duration(milliseconds: 2000),
        const Duration(milliseconds: 3000),
        const Duration(milliseconds: 4000),
        const Duration(milliseconds: 5000),
        const Duration(milliseconds: 6000),
      ],
      audioPaths: {
        'soprano': 'assets/audio/holy_holy_holy/soprano.mp3',
        'alto': 'assets/audio/holy_holy_holy/alto.mp3',
        'tenor': 'assets/audio/holy_holy_holy/tenor.mp3',
        'bass': 'assets/audio/holy_holy_holy/bass.mp3',
        'instrumental': 'assets/audio/holy_holy_holy/instrumental.mp3',
      },
    ),
  ];
}
