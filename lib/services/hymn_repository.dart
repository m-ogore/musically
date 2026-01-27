import '../models/hymn.dart';

/// Repository for managing hymn data for the SDA Hymnal (SDAH).
class HymnRepository {
  /// Gets all available hymns (1 through 695).
  Future<List<Hymn>> getAllHymns() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _generateAllHymns();
  }

  /// Gets a hymn by its ID (Hymn Number).
  Future<Hymn?> getHymnById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final allHymns = _generateAllHymns();
    try {
      return allHymns.firstWhere((hymn) => hymn.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Generates the full list of 695 SDA hymns.
  List<Hymn> _generateAllHymns() {
    final List<Hymn> hymns = [];
    for (int i = 1; i <= 695; i++) {
        final id = i.toString();
        if (id == '1') {
          hymns.add(_generateSDAH001());
        } else if (id == '2') {
          hymns.add(_generateSDAH002());
        } else if (id == '3') {
          hymns.add(_generateSDAH003());
        } else {
          hymns.add(_createPlaceholderHymn(id));
        }
    }
    return hymns;
  }

  /// SDAH #1: Praise to the Lord
  Hymn _generateSDAH001() {
    return Hymn(
      id: '1',
      hymnNumber: '1',
      title: 'Praise to the Lord',
      author: 'Joachim Neander',
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
      history: 'Written in 1680 by Joachim Neander.',
      notationData: '',
      noteTimestamps: [const Duration(seconds: 0)],
      audioPaths: {
        'soprano': 'assets/audio/1/soprano.mp3',
        'alto': 'assets/audio/1/alto.mp3',
        'tenor': 'assets/audio/1/tenor.mp3',
        'bass': 'assets/audio/1/bass.mp3',
        'instrumental': 'assets/audio/1/instrumental.mp3',
      },
      grandStaffData: '''
      {
        "keySignature": "G",
        "timeSignature": "3/4",
        "systems": [
          {
            "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "G4", "duration": "quarter", "timestamp": 0, "lyrics": ["1. Praise", "2. Praise", "3. Praise"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 1000, "lyrics": ["to", "to", "to"]},
                    {"note": "D5", "duration": "quarter", "timestamp": 2000, "lyrics": ["the", "the", "the"]}
                  ],
                  [
                    {"note": "B4", "duration": "quarter", "timestamp": 3000, "lyrics": ["Lord,", "Lord,", "Lord,"]},
                    {"note": "A4", "duration": "quarter", "timestamp": 4000, "lyrics": ["the", "who", "who"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 5000, "lyrics": ["Al-", "o'er", "doth"]}
                  ],
                  [
                    {"note": "F#4", "duration": "quarter", "timestamp": 6000, "lyrics": ["migh-", "all", "pros-"]},
                    {"note": "E4", "duration": "quarter", "timestamp": 7000, "lyrics": ["ty,", "things", "per"]},
                    {"note": "D4", "duration": "quarter", "timestamp": 8000, "lyrics": ["the", "so", "thy"]}
                  ],
                  [
                    {"note": "E4", "duration": "quarter", "timestamp": 9000, "lyrics": ["King", "won-", "work"]},
                    {"note": "F#4", "duration": "quarter", "timestamp": 10000, "lyrics": ["of", "drous-", "and"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 11000, "lyrics": ["cre-", "ly", "de-"]}
                  ]
                ]
              },
              "alto": {
                "measures": [
                  [{"note": "D4", "duration": "quarter", "timestamp": 0}, {"note": "D4", "duration": "quarter", "timestamp": 1000}, {"note": "G4", "duration": "quarter", "timestamp": 2000}],
                  [{"note": "G4", "duration": "quarter", "timestamp": 3000}, {"note": "F#4", "duration": "quarter", "timestamp": 4000}, {"note": "D4", "duration": "quarter", "timestamp": 5000}],
                  [{"note": "D4", "duration": "quarter", "timestamp": 6000}, {"note": "C4", "duration": "quarter", "timestamp": 7000}, {"note": "B3", "duration": "quarter", "timestamp": 8000}],
                  [{"note": "C4", "duration": "quarter", "timestamp": 9000}, {"note": "D4", "duration": "quarter", "timestamp": 10000}, {"note": "D4", "duration": "quarter", "timestamp": 11000}]
                ]
              }
            },
            "bass": {
              "tenor": {
                "measures": [
                  [{"note": "B3", "duration": "quarter", "timestamp": 0}, {"note": "B3", "duration": "quarter", "timestamp": 1000}, {"note": "B3", "duration": "quarter", "timestamp": 2000}],
                  [{"note": "D4", "duration": "quarter", "timestamp": 3000}, {"note": "D4", "duration": "quarter", "timestamp": 4000}, {"note": "B3", "duration": "quarter", "timestamp": 5000}],
                  [{"note": "A3", "duration": "quarter", "timestamp": 6000}, {"note": "A3", "duration": "quarter", "timestamp": 7000}, {"note": "G3", "duration": "quarter", "timestamp": 8000}],
                  [{"note": "G3", "duration": "quarter", "timestamp": 9000}, {"note": "A3", "duration": "quarter", "timestamp": 10000}, {"note": "B3", "duration": "quarter", "timestamp": 11000}]
                ]
              },
              "bass": {
                "measures": [
                  [{"note": "G3", "duration": "quarter", "timestamp": 0}, {"note": "G3", "duration": "quarter", "timestamp": 1000}, {"note": "G3", "duration": "quarter", "timestamp": 2000}],
                  [{"note": "G3", "duration": "quarter", "timestamp": 3000}, {"note": "D3", "duration": "quarter", "timestamp": 4000}, {"note": "G3", "duration": "quarter", "timestamp": 5000}],
                  [{"note": "D3", "duration": "quarter", "timestamp": 6000}, {"note": "A2", "duration": "quarter", "timestamp": 7000}, {"note": "G2", "duration": "quarter", "timestamp": 8000}],
                  [{"note": "C3", "duration": "quarter", "timestamp": 9000}, {"note": "D3", "duration": "quarter", "timestamp": 10000}, {"note": "G3", "duration": "quarter", "timestamp": 11000}]
                ]
              }
            }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "A4", "duration": "half", "timestamp": 12000, "lyrics": ["a-", "reign-", "fend"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 14000, "lyrics": ["tion!", "eth,", "thee;"]}
                  ],
                  [
                    {"note": "G4", "duration": "quarter", "timestamp": 15000, "lyrics": ["O", "Shel-", "Sure-"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 16000, "lyrics": ["my", "ters", "ly"]},
                    {"note": "D5", "duration": "quarter", "timestamp": 17000, "lyrics": ["soul,", "thee", "His"]}
                  ],
                  [
                    {"note": "B4", "duration": "quarter", "timestamp": 18000, "lyrics": ["praise", "un-", "good-"]},
                    {"note": "A4", "duration": "quarter", "timestamp": 19000, "lyrics": ["Him,", "der", "ness"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 20000, "lyrics": ["for", "His", "and"]}
                  ]
                ]
              },
              "alto": {
                "measures": [
                  [{"note": "D4", "duration": "half", "timestamp": 12000}, {"note": "D4", "duration": "quarter", "timestamp": 14000}],
                  [{"note": "D4", "duration": "quarter", "timestamp": 15000}, {"note": "D4", "duration": "quarter", "timestamp": 16000}, {"note": "G4", "duration": "quarter", "timestamp": 17000}],
                  [{"note": "G4", "duration": "quarter", "timestamp": 18000}, {"note": "F#4", "duration": "quarter", "timestamp": 19000}, {"note": "D4", "duration": "quarter", "timestamp": 20000}]
                ]
              }
            },
            "bass": {
              "tenor": {
                "measures": [
                  [{"note": "F#3", "duration": "half", "timestamp": 12000}, {"note": "G3", "duration": "quarter", "timestamp": 14000}],
                  [{"note": "B3", "duration": "quarter", "timestamp": 15000}, {"note": "B3", "duration": "quarter", "timestamp": 16000}, {"note": "B3", "duration": "quarter", "timestamp": 17000}],
                  [{"note": "D4", "duration": "quarter", "timestamp": 18000}, {"note": "D4", "duration": "quarter", "timestamp": 19000}, {"note": "B3", "duration": "quarter", "timestamp": 20000}]
                ]
              },
              "bass": {
                "measures": [
                  [{"note": "D3", "duration": "half", "timestamp": 12000}, {"note": "G2", "duration": "quarter", "timestamp": 14000}],
                  [{"note": "G3", "duration": "quarter", "timestamp": 15000}, {"note": "G3", "duration": "quarter", "timestamp": 16000}, {"note": "G3", "duration": "quarter", "timestamp": 17000}],
                  [{"note": "G3", "duration": "quarter", "timestamp": 18000}, {"note": "D3", "duration": "quarter", "timestamp": 19000}, {"note": "G3", "duration": "quarter", "timestamp": 20000}]
                ]
              }
            }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "F#4", "duration": "quarter", "timestamp": 22000, "lyrics": ["He", "wings,", "mer-"]},
                    {"note": "E4", "duration": "quarter", "timestamp": 23000, "lyrics": ["is", "yea,", "cy"]},
                    {"note": "D4", "duration": "quarter", "timestamp": 24000, "lyrics": ["thy", "so", "here"]}
                  ],
                  [
                    {"note": "E4", "duration": "quarter", "timestamp": 25000, "lyrics": ["health", "gen-", "dai-"]},
                    {"note": "F#4", "duration": "quarter", "timestamp": 26000, "lyrics": ["and", "tly", "ly"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 27000, "lyrics": ["sal-", "sus-", "at-"]}
                  ],
                  [
                    {"note": "A4", "duration": "half", "timestamp": 28000, "lyrics": ["va-", "tain-", "tend"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 31000, "lyrics": ["tion!", "eth!", "thee."]}
                  ]
                ]
              },
              "alto": {
                "measures": [
                  [{"note": "D4", "duration": "quarter", "timestamp": 22000}, {"note": "C4", "duration": "quarter", "timestamp": 23000}, {"note": "B3", "duration": "quarter", "timestamp": 24000}],
                  [{"note": "C4", "duration": "quarter", "timestamp": 25000}, {"note": "D4", "duration": "quarter", "timestamp": 26000}, {"note": "D4", "duration": "quarter", "timestamp": 27000}],
                  [{"note": "D4", "duration": "half", "timestamp": 28000}, {"note": "D4", "duration": "quarter", "timestamp": 31000}]
                ]
              }
            },
            "bass": {
              "tenor": {
                "measures": [
                  [{"note": "A3", "duration": "quarter", "timestamp": 22000}, {"note": "A3", "duration": "quarter", "timestamp": 23000}, {"note": "G3", "duration": "quarter", "timestamp": 24000}],
                  [{"note": "G3", "duration": "quarter", "timestamp": 25000}, {"note": "A3", "duration": "quarter", "timestamp": 26000}, {"note": "B3", "duration": "quarter", "timestamp": 27000}],
                  [{"note": "F#3", "duration": "half", "timestamp": 28000}, {"note": "G3", "duration": "quarter", "timestamp": 31000}]
                ]
              },
              "bass": {
                "measures": [
                  [{"note": "D3", "duration": "quarter", "timestamp": 22000}, {"note": "A2", "duration": "quarter", "timestamp": 23000}, {"note": "G2", "duration": "quarter", "timestamp": 24000}],
                  [{"note": "C3", "duration": "quarter", "timestamp": 25000}, {"note": "D3", "duration": "quarter", "timestamp": 26000}, {"note": "G3", "duration": "quarter", "timestamp": 27000}],
                  [{"note": "D3", "duration": "half", "timestamp": 28000}, {"note": "G2", "duration": "quarter", "timestamp": 31000}]
                ]
              }
            }
          },
          {
             "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "G4", "duration": "half", "timestamp": 34000, "lyrics": ["All", "Hast", "Pon-"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 36000, "lyrics": ["ye", "thou", "der"]}
                  ],
                  [
                    {"note": "A4", "duration": "half", "timestamp": 37000, "lyrics": ["who", "not", "a-"]},
                    {"note": "A4", "duration": "quarter", "timestamp": 39000, "lyrics": ["hear,", "seen", "new"]}
                  ],
                  [
                    {"note": "B4", "duration": "half", "timestamp": 40000, "lyrics": ["now", "how", "what"]},
                    {"note": "B4", "duration": "quarter", "timestamp": 42000, "lyrics": ["to", "thy", "the"]}
                  ]
                ]
              }
             },
             "bass": {
                "bass": {
                  "measures": [
                    [{"note": "G3", "duration": "half", "timestamp": 34000}, {"note": "B3", "duration": "quarter", "timestamp": 36000}],
                    [{"note": "D4", "duration": "half", "timestamp": 37000}, {"note": "F#3", "duration": "quarter", "timestamp": 39000}],
                    [{"note": "G3", "duration": "half", "timestamp": 40000}, {"note": "G3", "duration": "quarter", "timestamp": 42000}]
                  ]
                }
             }
          },
          {
             "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "C5", "duration": "half", "timestamp": 43000, "lyrics": ["His", "thy", "Al-"]},
                    {"note": "B4", "duration": "quarter", "timestamp": 45000, "lyrics": ["tem-", "de-", "migh-"]}
                  ],
                  [
                    {"note": "A4", "duration": "quarter", "timestamp": 46000, "lyrics": ["ple", "sires", "ty"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 47000, "lyrics": ["draw", "e'er", "can"]},
                    {"note": "F#4", "duration": "quarter", "timestamp": 48000, "lyrics": ["near;", "have", "do,"]}
                  ]
                ]
              }
             },
             "bass": {
                "bass": {
                  "measures": [
                    [{"note": "C3", "duration": "half", "timestamp": 43000}, {"note": "G3", "duration": "quarter", "timestamp": 45000}],
                    [{"note": "D3", "duration": "quarter", "timestamp": 46000}, {"note": "E3", "duration": "quarter", "timestamp": 47000}, {"note": "D3", "duration": "quarter", "timestamp": 48000}]
                  ]
                }
             }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [
                    {"note": "D4", "duration": "quarter", "timestamp": 49000, "lyrics": ["Join", "Grant-", "If"]},
                    {"note": "E4", "duration": "quarter", "timestamp": 50000, "lyrics": ["me", "ed", "with"]},
                    {"note": "F#4", "duration": "quarter", "timestamp": 51000, "lyrics": ["in", "in", "His"]}
                  ],
                  [
                    {"note": "G4", "duration": "half", "timestamp": 52000, "lyrics": ["glad", "what", "love"]},
                    {"note": "A4", "duration": "quarter", "timestamp": 55000, "lyrics": ["a-", "He", "He"]}
                  ],
                  [
                    {"note": "G4", "duration": "half", "timestamp": 56000, "lyrics": ["do-", "or-", "be-"]},
                    {"note": "G4", "duration": "quarter", "timestamp": 59000, "lyrics": ["ra-", "dain-", "friend"]}
                  ],
                  [
                    {"note": "G4", "duration": "whole", "timestamp": 60000, "lyrics": ["tion!", "eth?", "thee."]}
                  ]
                ]
              }
            },
            "bass": {
              "bass": {
                "measures": [
                   [{"note": "G2", "duration": "quarter", "timestamp": 49000}, {"note": "C3", "quarter": 50000, "duration": "quarter", "timestamp": 50000}, {"note": "D3", "duration": "quarter", "timestamp": 51000}],
                   [{"note": "E3", "duration": "half", "timestamp": 52000}, {"note": "C3", "duration": "quarter", "timestamp": 55000}],
                   [{"note": "D3", "duration": "half", "timestamp": 56000}, {"note": "D3", "duration": "quarter", "timestamp": 59000}],
                   [{"note": "G2", "duration": "whole", "timestamp": 60000}]
                ]
              }
            }
          }
        ]
      }
      ''',
      systemTimestamps: [
        Duration.zero, 
        const Duration(milliseconds: 12000), 
        const Duration(milliseconds: 22000),
        const Duration(milliseconds: 34000),
        const Duration(milliseconds: 43000),
        const Duration(milliseconds: 49000)
      ],
      audioOffset: const Duration(seconds: 15),
      tempoFactor: 1.2,
      musicXmlPath: 'assets/notation/1.xml',
    );
  }

  /// SDAH #2: All Creatures of Our God and King
  Hymn _generateSDAH002() {
    return Hymn(
      id: '2',
      hymnNumber: '2',
      title: 'All Creatures of Our God and King',
      author: 'St. Francis of Assisi',
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
Ye clouds that ride in heaven along,
O praise Him! Alleluia!
Thou rising morn, in praise rejoice,
Ye lights of evening, find a voice!
'''.trim(),
      history: 'Based on Canticle of the Sun by St. Francis of Assisi (1225).',
      notationData: '',
      noteTimestamps: [const Duration(seconds: 0)],
      audioPaths: {
        'soprano': 'assets/audio/2/soprano.mp3',
        'alto': 'assets/audio/2/alto.mp3',
        'tenor': 'assets/audio/2/tenor.mp3',
        'bass': 'assets/audio/2/bass.mp3',
        'instrumental': 'assets/audio/2/instrumental.mp3',
      },
      grandStaffData: '''
      {
        "keySignature": "Eb",
        "timeSignature": "3/2",
        "systems": [
          {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "Eb4", "duration": "half", "timestamp": 0, "lyrics": ["1. All", "2. Thou"]}, {"note": "Eb4", "duration": "half", "timestamp": 2000, "lyrics": ["crea-", "rush-"]}, {"note": "Eb4", "duration": "half", "timestamp": 4000, "lyrics": ["tures", "ing"]}],
                  [{"note": "G4", "duration": "half", "timestamp": 6000, "lyrics": ["of", "wind"]}, {"note": "F4", "duration": "half", "timestamp": 8000, "lyrics": ["our", "that"]}, {"note": "Eb4", "duration": "half", "timestamp": 10000, "lyrics": ["God", "art"]}]
                ]
              }
            },
            "bass": {
              "bass": {
                "measures": [
                  [{"note": "Eb3", "duration": "half", "timestamp": 0}, {"note": "Bb2", "duration": "half", "timestamp": 2000}, {"note": "Ab2", "duration": "half", "timestamp": 4000}],
                  [{"note": "Eb3", "duration": "half", "timestamp": 6000}, {"note": "Bb2", "duration": "half", "timestamp": 8000}, {"note": "Eb3", "duration": "half", "timestamp": 10000}]
                ]
              }
            }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "Ab4", "duration": "half", "timestamp": 12000, "lyrics": ["and", "so"]}, {"note": "G4", "duration": "half", "timestamp": 14000, "lyrics": ["King,", "strong,"]}],
                  [{"note": "F4", "duration": "half", "timestamp": 16000, "lyrics": ["Lift", "Ye"]}, {"note": "Eb4", "duration": "half", "timestamp": 18000, "lyrics": ["up", "clouds"]}, {"note": "D4", "duration": "half", "timestamp": 20000, "lyrics": ["your", "that"]}]
                ]
              }
            },
            "bass": { "bass": { "measures": [ [{"note": "F3", "duration": "half", "timestamp": 12000}], [{"note": "Bb2", "duration": "half", "timestamp": 16000}] ] } }
          },
           {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "Eb4", "duration": "half", "timestamp": 22000, "lyrics": ["voice", "ride"]}, {"note": "F4", "duration": "half", "timestamp": 24000, "lyrics": ["and", "in"]}],
                  [{"note": "G4", "duration": "half", "timestamp": 26000, "lyrics": ["with", "heav-"]}, {"note": "Ab4", "duration": "half", "timestamp": 28000, "lyrics": ["us", "en"]}, {"note": "Bb4", "duration": "half", "timestamp": 30000, "lyrics": ["sing,", "a-"]}]
                ]
              }
            },
            "bass": { "bass": { "measures": [ [{"note": "G2", "duration": "half", "timestamp": 22000}], [{"note": "Eb3", "duration": "half", "timestamp": 26000}] ] } }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "C5", "duration": "whole", "timestamp": 32000, "lyrics": ["Al-", "long,"]}, {"note": "Bb4", "duration": "half", "timestamp": 36000, "lyrics": ["le-", "O"]}],
                  [{"note": "Ab4", "duration": "whole", "timestamp": 38000, "lyrics": ["lu-", "praise"]}, {"note": "G4", "duration": "half", "timestamp": 42000, "lyrics": ["ia!", "Him!"]}]
                ]
              }
            },
            "bass": { "bass": { "measures": [ [{"note": "Ab2", "duration": "whole", "timestamp": 32000}], [{"note": "Eb3", "duration": "whole", "timestamp": 38000}] ] } }
          }
        ]
      }
      ''',
      systemTimestamps: [
        Duration.zero, 
        const Duration(milliseconds: 12000), 
        const Duration(milliseconds: 22000), 
        const Duration(milliseconds: 32000)
      ],
    );
  }

  /// SDAH #3: God Himself Is With Us
  Hymn _generateSDAH003() {
    return Hymn(
      id: '3',
      hymnNumber: '3',
      title: 'God Himself Is With Us',
      author: 'Gerhard Tersteegen',
      lyrics: '''
Verse 1:
God Himself is with us;
Let us all adore Him,
And with awe appear before Him.
God is in His temple,
All within keep silence,
Prostrate lie with deepest relevance.

Verse 2:
God Himself is with us;
Whom the angelic legions
Serve with awe in heavenly regions.
"Holy, holy, holy,"
Sing the hosts of heaven;
Praise to God be ever given.
'''.trim(),
      history: 'German hymn from 1729 by Gerhard Tersteegen.',
      notationData: '',
      noteTimestamps: [const Duration(seconds: 0)],
      audioPaths: {
        'soprano': 'assets/audio/3/soprano.mp3',
        'alto': 'assets/audio/3/alto.mp3',
        'tenor': 'assets/audio/3/tenor.mp3',
        'bass': 'assets/audio/3/bass.mp3',
        'instrumental': 'assets/audio/3/instrumental.mp3',
      },
      grandStaffData: '''
      {
        "keySignature": "G",
        "timeSignature": "4/4",
        "systems": [
          {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "G4", "duration": "half", "timestamp": 0, "lyrics": ["1. God", "2. God"]}, {"note": "A4", "duration": "quarter", "timestamp": 2000, "lyrics": ["Him-", "Him-"]}, {"note": "G4", "duration": "quarter", "timestamp": 3000, "lyrics": ["self", "self"]}],
                  [{"note": "B4", "duration": "half", "timestamp": 4000, "lyrics": ["is", "is"]}, {"note": "C5", "duration": "quarter", "timestamp": 6000, "lyrics": ["with", "with"]}, {"note": "B4", "duration": "quarter", "timestamp": 7000, "lyrics": ["us;", "us;"]}]
                ]
              }
            },
            "bass": {
              "bass": {
                "measures": [
                  [{"note": "G3", "duration": "half", "timestamp": 0}, {"note": "D3", "duration": "quarter", "timestamp": 2000}, {"note": "E3", "duration": "quarter", "timestamp": 3000}],
                  [{"note": "G2", "duration": "half", "timestamp": 4000}, {"note": "C3", "duration": "quarter", "timestamp": 6000}, {"note": "G3", "duration": "quarter", "timestamp": 7000}]
                ]
              }
            }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                  [{"note": "A4", "duration": "half", "timestamp": 8000, "lyrics": ["Let", "Whom"]}, {"note": "G4", "duration": "quarter", "timestamp": 10000, "lyrics": ["us", "the"]}, {"note": "A4", "duration": "quarter", "timestamp": 11000, "lyrics": ["all", "an-"]}],
                  [{"note": "B4", "duration": "half", "timestamp": 12000, "lyrics": ["a-", "gel-"]}, {"note": "A4", "duration": "quarter", "timestamp": 14000, "lyrics": ["dore", "ic"]}, {"note": "G4", "duration": "quarter", "timestamp": 15000, "lyrics": ["Him,", "le-"]}]
                ]
              }
            },
            "bass": { "bass": { "measures": [ [{"note": "D3", "duration": "half", "timestamp": 8000}], [{"note": "G2", "duration": "half", "timestamp": 12000}] ] } }
          },
          {
            "treble": {
              "soprano": {
                "measures": [
                   [{"note": "C5", "duration": "half", "timestamp": 16000, "lyrics": ["And", "gions"]}, {"note": "B4", "duration": "quarter", "timestamp": 18000, "lyrics": ["with", "Serve"]}, {"note": "A4", "duration": "quarter", "timestamp": 19000, "lyrics": ["awe", "with"]}],
                   [{"note": "G4", "duration": "whole", "timestamp": 20000, "lyrics": ["ap-", "awe"]}]
                ]
              }
            },
            "bass": { "bass": { "measures": [ [{"note": "C3", "duration": "half", "timestamp": 16000}], [{"note": "G2", "duration": "whole", "timestamp": 20000}] ] } }
          }
        ]
      }
      ''',
      systemTimestamps: [Duration.zero, const Duration(milliseconds: 8000), const Duration(milliseconds: 16000)],
    );
  }

  Hymn _createPlaceholderHymn(String id) {
    return Hymn(
      id: id,
      hymnNumber: id,
      title: 'SDA Hymn #$id',
      author: 'SDAH Placeholder',
      history: 'History not available.',
      lyrics: 'Lyrics not available.',
      notationData: '',
      noteTimestamps: [],
      audioPaths: {'soprano': '', 'alto': '', 'tenor': '', 'bass': '', 'instrumental': ''},
      grandStaffData: '''
      {
        "systems": [
          {
            "keySignature": "C",
            "timeSignature": "4/4",
            "treble": { "soprano": { "measures": [[]] } },
            "bass": { "bass": { "measures": [[]] } }
          }
        ]
      }
      ''',
    );
  }
}