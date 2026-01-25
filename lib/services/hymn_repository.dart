import '../models/hymn.dart';

/// Repository for managing hymn data
/// In a production app, this would fetch from a database or API
class HymnRepository {
  /// Gets all available hymns
  Future<List<Hymn>> getAllHymns() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _sampleHymns;
  }

  /// Gets a hymn by its ID
  Future<Hymn?> getHymnById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      return _sampleHymns.firstWhere((hymn) => hymn.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sample hymns for testing
  static final List<Hymn> _sampleHymns = [
    Hymn(
      id: '1',
      title: 'Amazing Grace',
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
      id: '2',
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
      id: '3',
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
