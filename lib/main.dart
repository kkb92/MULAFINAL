import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Player {
  String name;
  int points;
  bool isSelectable;
  bool isVisible; // Neue Eigenschaft für den Sichtbarkeitsstatus
  int totalPoints; // Hinzugefügte Eigenschaft für die Gesamtpunktzahl

  Player(this.name, this.points, this.isSelectable, {this.isVisible = true, this.totalPoints = 0});
}

class PointsOption {
  String label;
  int value;

  PointsOption(this.label, this.value);

  static PointsOption plusOne() {
    return PointsOption('+1', 1);
  }

  static PointsOption plusTwo() {
    return PointsOption('+2', 2);
  }

  static PointsOption plusThree() {
    return PointsOption('+3', 3);
  }

  static PointsOption plusFour() {
    return PointsOption('+4', 4);
  }
}

class PointsMultiplier {
  String label;
  int multiplier;

  PointsMultiplier(this.label, this.multiplier);
}

class RoundResult {
  int roundNumber;
  Map<String, int> playerPoints;

  RoundResult(this.roundNumber, this.playerPoints);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Player> players = [];
  int selectedPlayerCount = 3;
  bool pointsGiven = false; // Neue Variable für den Zustand der Punktevergabe
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('SPIELERAUSWAHL'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 3; i <= 5; i++)
                  ElevatedButton(
                    onPressed: () async {
                      // Setze die ausgewählte Spieleranzahl
                      setState(() {
                        selectedPlayerCount = i;
                      });

                      // Lasse die Spieler benennen
                      await _getPlayersNames(i);

                      // Navigiere zur nächsten Seite
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayersTablePage(players),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedPlayerCount == i ? Colors.blue[200] : Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    child: Text(
                      '$i', // Änderung des Textes
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPlayersNames(int playerCount) async {
    List<Player> selectedPlayers = [];

    for (int i = 0; i < playerCount; i++) {
      String? playerName = await _getPlayerName(context, i + 1);
      selectedPlayers.add(Player(playerName?.toUpperCase() ?? 'SPIELER ${i + 1}', 15, true));
    }

    setState(() {
      players = selectedPlayers;
    });
  }

  Future<String?> _getPlayerName(BuildContext context, int playerNumber) async {
    TextEditingController controller = TextEditingController();

    // Hier kannst du das UI für die Spielerbenennung direkt in der Spielerauswahl erstellen
    // und den TextEditingController verwenden, um den eingegebenen Namen zu erhalten.

    // Beispiel für ein einfaches UI für die Spielerbenennung:
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Spieler $playerNumber'),
          content: Column(
            children: [
              Text('Gib den Namen für Spieler $playerNumber ein:'),
              TextField(
                controller: controller,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class PlayersTablePage extends StatefulWidget {
  final List<Player> players;

  PlayersTablePage(this.players);

  @override
  _PlayersTablePageState createState() => _PlayersTablePageState();
}

class _PlayersTablePageState extends State<PlayersTablePage> {
  Player? selectedPlayer;
  PointsOption? selectedPointsOption;
  PointsMultiplier? selectedMultiplier;
  int calculatedPoints = 0;
  int roundNumber = 1;
  List<RoundResult> roundResults = [];
  String? selectedValue;
  int currentRound = 1; // Hinzugefügte Variable für die Rundenanzeige


  List<PointsOption> pointsOptions = [
    PointsOption('-5', -5),
    PointsOption('-4', -4),
    PointsOption('-3', -3),
    PointsOption('-2', -2),
    PointsOption('-1', -1),
  ];

  List<PointsMultiplier> pointsMultipliers = [
    PointsMultiplier('x1', 1),
    PointsMultiplier('x2', 2),
    PointsMultiplier('x4', 4),
    PointsMultiplier('x8', 8),
    PointsMultiplier('x16', 16),
    PointsMultiplier('x32', 32),
    PointsMultiplier('x64', 64),
  ];

  @override
  void initState() {
    super.initState();
    // Set the default multiplier when the state is initialized
    selectedMultiplier = pointsMultipliers[0]; // Wähle den ersten Multiplikator aus
  }

  Map<String, int> calculateTotalPointsPerPlayer() {
    Map<String, int> totalPointsPerPlayer = {};

    for (var player in widget.players) {
      totalPointsPerPlayer[player.name] = 0;
    }

    for (var roundResult in roundResults) {
      for (var entry in roundResult.playerPoints.entries) {
        // Berücksichtige nur Punkte ab 0 (+-1)
        if (entry.value >= 0) {
          totalPointsPerPlayer[entry.key] = (totalPointsPerPlayer[entry.key] ?? 0) + entry.value;
        }
      }
    }

    // Sortiere die Spieler basierend auf ihren Gesamtpunkten in aufsteigender Reihenfolge
    var sortedPlayers = totalPointsPerPlayer.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Erstelle eine neue Map mit sortierten Einträgen
    Map<String, int> sortedTotalPointsPerPlayer = {};
    for (var entry in sortedPlayers) {
      sortedTotalPointsPerPlayer[entry.key] = entry.value;
    }

    return sortedTotalPointsPerPlayer;
  }

  void _editPoints(Player player) async {
    TextEditingController controller = TextEditingController();
    controller.text = player.points.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Punktestand bearbeiten"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Neuer Punktestand"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                // Überprüfe, ob die Eingabe gültig ist
                if (controller.text.isNotEmpty) {
                  int newPoints = int.parse(controller.text);
                  setState(() {
                    player.points = newPoints;
                    // Optional: Füge hier die Aktualisierung der Gesamtpunktzahl hinzu
                  });
                }
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  void resetPoints() {
    setState(() {
      for (var player in widget.players) {
        player.points = 15;
      }
    });
  }

  void endRound() {
    Map<String, int> playerPoints = {};
    for (var player in widget.players) {
      playerPoints[player.name] = player.points;
    }

    RoundResult roundResult = RoundResult(roundNumber, playerPoints);
    roundResults.add(roundResult);
    roundNumber++;

    resetPoints();
  }

  void resetRound() {
    setState(() {
      roundNumber = 1;
      roundResults.clear();
      resetPoints();

      // Multiplikator auf x1 zurücksetzen
      selectedMultiplier = pointsMultipliers[0];
      selectedValue = 'x${selectedMultiplier!.multiplier}';

      // Rundenanzahl zurücksetzen
      currentRound = 1;
    });
  }

  void showRoundResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, int> totalPointsPerPlayer = calculateTotalPointsPerPlayer();

        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PUNKTEÜBERSICHT',
                  style: TextStyle(
                    color: Colors.blueAccent, // Futuristische Farbpalette
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20.0),
                // Gesamtpunkte
                Text(
                  'GESAMTPUNKTE',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: totalPointsPerPlayer.entries.map((entry) {
                    int displayedPoints = entry.value < 0 ? 0 : entry.value;

                    return ListTile(
                      title: Text(
                        '${entry.key}: $displayedPoints',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        Icons.trending_up, // Beispielhaftes futuristisches Icon
                        color: Colors.blueAccent,
                      ),
                    );
                  }).toList(),
                ),
                Divider(
                  color: Colors.grey,
                ),
                // Rundenergebnisse
                Text(
                  'RUNDENERGEBNISSE',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: roundResults.length,
                    itemBuilder: (context, index) {
                      RoundResult roundResult = roundResults[index];
                      return Card(
                        elevation: 5, // Schatten für Tiefe
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'RUNDE ${roundResult.roundNumber}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: roundResult.playerPoints.entries.map((entry) {
                                int displayedPoints = entry.value < 0 ? 0 : entry.value;

                                return ListTile(
                                  title: Text(
                                    '${entry.key}: $displayedPoints',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.star, // Beispielhaftes futuristisches Icon
                                    color: Colors.blueAccent,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('OK'),
                ),
                SizedBox(height: 10.0), // Platz für die Rundenanzahl
                Text(
                  'Aktuelle Runde: $currentRound',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
        currentRound++;
      },
    );
  }


  void _applyMPlus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Ist der Mula wirklich nicht durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMPlusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }

  void _applyMMinus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Ist der Mula wirklich durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMMinusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }

  void _applyMPlusConfirmed() {
    setState(() {
      selectedPlayer!.points += 20 * selectedMultiplier!.multiplier;

      // Den restlichen Spielern -20 Punkte hinzufügen
      for (var player in widget.players) {
        if (player != selectedPlayer) {
          player.points -= 20 * selectedMultiplier!.multiplier;
          if (player.points <= 0) {
            player.points = 0;
          }
        }
      }

      // Multiplikator auf x1 zurücksetzen
      selectedMultiplier = pointsMultipliers[0];
      selectedValue = 'x${selectedMultiplier!.multiplier}';
    });

    // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
    bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

    // Trigger die endRound-Funktion und aktualisiere die Rundenanzahl
    if (anyPlayerBelowZero) {
      endRound();
      setState(() {
        currentRound++;
      });
    }
  }

  void _applyMMinusConfirmed() {
    setState(() {
      selectedPlayer!.points -= 20 * selectedMultiplier!.multiplier;
      if (selectedPlayer!.points <= 0) {
        selectedPlayer!.points = 0;
      }

      // Den restlichen Spielern +20 Punkte hinzufügen
      for (var player in widget.players) {
        if (player != selectedPlayer) {
          player.points += 20 * selectedMultiplier!.multiplier;
          if (player.points <= 0) {
            player.points = 0;
          }
        }
      }

      // Multiplikator auf x1 zurücksetzen
      selectedMultiplier = pointsMultipliers[0];
      selectedValue = 'x${selectedMultiplier!.multiplier}';
    });

    // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
    bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

    // Trigger die endRound-Funktion und aktualisiere die Rundenanzahl
    if (anyPlayerBelowZero) {
      endRound();
      setState(() {
        currentRound++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('W E L I'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                showRoundResults();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: Text('PUNKTESTAND'),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Hinzugefügte Anzeige der aktuellen Rundenanzahl
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Runde: $currentRound',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0.1,
                mainAxisSpacing: 0.1,
              ),
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                Player currentPlayer = widget.players[index];
                bool isSelected = selectedPlayer == currentPlayer;

                if (currentPlayer.isVisible) {
                  return IgnorePointer(
                    ignoring: !currentPlayer.isVisible,
                    child: InkWell(
                      onTapDown: (details) {
                        setState(() {
                          selectedPlayer = isSelected ? null : currentPlayer;
                        });
                      },
                      onLongPress: () {
                        _handleMinusButtonPress(currentPlayer);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: 110,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Hier wird der Dialog zum Bearbeiten des Punktestands geöffnet
                                            _editPoints(currentPlayer);
                                          },
                                          child: Text(
                                            '${currentPlayer.points}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${calculateTotalPointsPerPlayer()[currentPlayer.name]}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          currentPlayer.name,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () {
                                      _handleLeftXButtonPress(currentPlayer);
                                    },
                                    child: ClipOval(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      _handleRightXButtonPress(currentPlayer);
                                    },
                                    child: ClipOval(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showMultiplierMenu(context);
                },
                icon: Container(),
                label: Text(
                  selectedMultiplier != null
                      ? 'x${selectedMultiplier!.multiplier}'
                      : '*',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.blue[200]
                      : Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyMPlus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.redAccent
                      : Colors.redAccent[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  'M+',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyMMinus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMultiplier != null
                      ? Colors.green
                      : Colors.green[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  'M-',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-1', -1);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-1'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-1',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-2', -2);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-2'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-2',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-3', -3);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-3'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-3',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-4', -4);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-4'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-4',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPointsOption = PointsOption('-5', -5);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPointsOption?.label == '-5'
                      ? Colors.blue[200]
                      : Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  '-5',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedPlayer != null &&
                        selectedPointsOption != null &&
                        selectedMultiplier != null) {
                      _applyPointsToPlayer(
                          selectedPlayer!, selectedPointsOption!.value);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text('ÜBERNEHMEN'),
                ),
                ElevatedButton(
                  onPressed: () {
                    endRound();
                    setState(() {
                      currentRound++;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text('NEUE RUNDE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    resetRound();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _confirmNewRound() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Neue Runde starten?"),
          content: Text("Bist du Sicher, dass du eine neue Runde starten willst?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe die Dialogbox
              },
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe die Dialogbox
                endRound(); // Starte die neue Runde, wenn bestätigt
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Neue Runde starten"),
            ),
          ],
        );
      },
    );
  }

  void _handleLeftXButtonPress(Player player) {
    // Behandele den Klick auf das linke X für den angegebenen Spieler
    // Füge +5 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 5 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';
        });
      }
    }
  }

  void _handleRightXButtonPress(Player player) {
    // Behandle den Klick auf das rechte X für den angegebenen Spieler
    // Füge +10 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 10 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';
        });
      }
    }
  }

  void _handleMinusButtonPress(Player player) {
    // Behandle den Klick auf den Minus-Button für den angegebenen Spieler
    // Füge +1 Punkt zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';
        });
      }
    }
  }

  void _applyPlusOne(Player player) {
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
      });
    }
  }

  void _applyPointsToPlayer(Player player, int points) {
    // Füge Punkte zum Spieler hinzu unter Berücksichtigung des Multiplikators
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += points * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;

        // Stelle sicher, dass kein Spieler unter 0 Punkte fällt
        if (player.points < 0) {
          player.points = 0;
        }

        player.isVisible = false; // Spieler ausblenden
      });

      // Aktualisiere die Gesamtpunktzahl des Spielers
      updateTotalPoints(player);

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';
        });
      }
    }
  }

  void updateTotalPoints(Player player) {
    // Aktualisiere die Gesamtpunktzahl des Spielers
    Map<String, int> totalPointsPerPlayer = calculateTotalPointsPerPlayer();
    int totalPoints = totalPointsPerPlayer[player.name] ?? 0;
    totalPoints += calculatedPoints;

    // Stelle sicher, dass keine Minuspunkte für die Gesamtpunktzahl angezeigt werden
    totalPoints = totalPoints < 0 ? 0 : totalPoints;

    totalPointsPerPlayer[player.name] = totalPoints;

    // Setze die Gesamtpunktzahl für jeden Spieler neu
    setState(() {
      totalPointsPerPlayer = totalPointsPerPlayer;

      // Hier wird der aktuelle Punktestand zum totalPoints der Spieler hinzugefügt
      player.totalPoints = totalPoints;
    });
  }


  void _showMultiplierMenu(BuildContext context) {
    setState(() {
      // Hier wird der Index des aktuellen Multiplikators gefunden
      int currentIndex = pointsMultipliers.indexOf(selectedMultiplier!);

      // Hier wird der Index des nächsten Multiplikators berechnet
      int nextIndex = (currentIndex + 1) % pointsMultipliers.length;

      // Hier wird der nächste Multiplikator ausgewählt
      selectedMultiplier = pointsMultipliers[nextIndex];
      selectedValue = 'x${selectedMultiplier!.multiplier}';
    });
  }
}
