import 'package:flutter/material.dart';
import 'dart:math';

enum TileState { covered, blown, open, flagged, revealed }

///* use index +1 for difficulty multiplier
enum Difficulty { HARD, MEDIUM, EASY }

final int rows = 8;
final int cols = 8;

void main() => runApp(MineSweeper());

class MineSweeper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mine Sweaper',
      home: Board(),
    );
  }
}

class Board extends StatefulWidget {
  @override
  BoardState createState() => BoardState();
}

class BoardState extends State<Board> with TickerProviderStateMixin {
  static final difficulty = Difficulty.EASY;
  final int numOfMines = 8 + (8 * (1.0 / (difficulty.index + 1.0))).floor();

  List<List<TileState>> uiState;
  List<List<bool>> tiles;

  AnimationController _controller;

  void resetBoard() {
    uiState = List<List<TileState>>.generate(rows, (row) {
      return List<TileState>.filled(cols, TileState.covered);
    });

    tiles = List<List<bool>>.generate(rows, (row) {
      return List<bool>.filled(cols, false);
    });

    Random random = Random();
    int rem = numOfMines;
    //TODO: add loading indicator
    while (rem > 0) {
      int pos = random.nextInt(rows * cols);
      int r = pos ~/ rows;
      int c = pos % cols;
      if (!tiles[r][c]) {
        tiles[r][c] = true;
        rem--;
      }
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

  }

  @override
  void initState() {
    resetBoard();
    super.initState();
  }

  Widget buildBoard(BuildContext context) {
    List<Row> boardRow = <Row>[];
    for (int y = 0; y < rows; y++) {
      List<Widget> rowsChildren = <Widget>[];
      for (int x = 0; x < cols; x++) {
        TileState state = uiState[y][x];
        int count = mineCount(x, y);
        if (state == TileState.covered || state == TileState.flagged) {
          _controller.forward();
          rowsChildren.add(
            GestureDetector(
              onTap: () {
                print('tapped on $y $x');
                probe(x, y);
              },
              onLongPress: () {
                flag(x, y);
              },
              child: Listener(
                child: FadeTransition(
                  opacity: _controller,
                  child: CoveredMineTile(
                    flagged: state == TileState.flagged,
                    posX: x,
                    posY: y,
                  ),
                ),
              ),
            ),
          );
        } else {
          rowsChildren.add(OpenMineTile(state, count));
        }
      }
      boardRow.add(Row(
        children: rowsChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(y),
      ));
    }

    return Container(
      color: Colors.grey[700],
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: boardRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Mine Sweeper'),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: buildBoard(context),
        ),
      ),
    );
  }

  void probe(int x, int y) {
    if (uiState[y][x] == TileState.flagged) return;
    setState(() {
      if (tiles[y][x]) {
        uiState[y][x] = TileState.blown;
      } else {
        open(x, y);
      }
    });
  }

  void open(int x, int y) {
    if (!inBoard(x, y)) return;
    if (uiState[y][x] == TileState.open) return;
    uiState[y][x] = TileState.open;

    if (mineCount(x, y) > 0) return;

    open(x + 1, y);
    open(x - 1, y);
    open(x, y + 1);
    open(x, y - 1);
    open(x - 1, y - 1);
    open(x + 1, y + 1);
    open(x - 1, y + 1);
    open(x + 1, y - 1);
  }

  void flag(int x, int y) {
    setState(() {
      if (uiState[y][x] == TileState.flagged) {
        uiState[y][x] = TileState.covered;
      } else {
        uiState[y][x] = TileState.flagged;
      }
    });
  }

  int mineCount(int x, int y) {
    int count = 0;
    count += bombs(x - 1, y);
    count += bombs(x + 1, y);
    count += bombs(x, y - 1);
    count += bombs(x, y + 1);
    count += bombs(x - 1, y - 1);
    count += bombs(x + 1, y + 1);
    count += bombs(x + 1, y - 1);
    count += bombs(x - 1, y + 1);
    return count;
  }

  int bombs(int x, int y) => inBoard(x, y) && tiles[y][x] ? 1 : 0;

  bool inBoard(int x, int y) => x >= 0 && x < cols && y >= 0 && y < rows;
}

Widget buildInnerTile(Widget child, double size) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: size,
    width: size,
    child: child,
    color: Colors.grey,
  );
}

Widget buildTile(Widget child, double size) {
  return Container(
    padding: EdgeInsets.all(1.0),
    margin: EdgeInsets.all(2.0),
    height: size,
    width: size,
    color: Colors.grey[400],
    child: child,
  );
}

class CoveredMineTile extends StatelessWidget {
  final bool flagged;
  final int posX;
  final int posY;

  const CoveredMineTile({Key key, this.flagged, this.posX, this.posY})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final size = (w - (2 * 10) - (rows * 4)) / rows;
    Widget text;
    if (flagged) {
      text = Center(
        child: RichText(
          text: TextSpan(
              text: "\u2691",
              style: TextStyle(
                fontSize: size / 2,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          textAlign: TextAlign.center,
        ),
      );
    }

    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: size,
      width: size,
      color: Colors.grey[350],
      child: text,
    );

    return buildTile(innerTile, size);
  }
}

class OpenMineTile extends StatelessWidget {
  final TileState state;
  final int number;

  OpenMineTile(this.state, this.number);

  final List textColor = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    Widget text;

    final w = MediaQuery.of(context).size.width;
    final size = (w - (2 * 10) - (rows * 4)) / rows;

    if (state == TileState.open) {
      if (number != 0) {
        text = Center(
          child: RichText(
            text: TextSpan(
              text: '$number',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor[number-1],
                fontSize: size / 2,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
    } else {
      text = Center(
        child: RichText(
          text: TextSpan(
            text: '\u2739',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size / 2,
              color: Colors.red,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return buildInnerTile(text, size);
  }
}
