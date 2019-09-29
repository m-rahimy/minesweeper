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

class BoardState extends State<Board> {
  static final difficulty = Difficulty.EASY;
  final int numOfMines = 8 + (8 * (1.0 / (difficulty.index + 1.0))).floor();

  List<List<TileState>> uiState;
  List<List<bool>> tiles;

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
  }

  @override
  void initState() {
    resetBoard();
    print(numOfMines);
    super.initState();
  }

  Widget buildBoard(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final containerW = (w - (2 * 10) - (rows * 4)) / rows;
    List<Row> boardRow = <Row>[];
    for (int i = 0; i < rows; i++) {
      List<Widget> rowsChildren = <Widget>[];
      for (int j = 0; j < cols; j++) {
        TileState state = uiState[i][j];
        if (state == TileState.covered) {
          rowsChildren.add(GestureDetector(
              onTap: () {
                print('tapped on $i $j');
              },
              child: Listener(child: buildInnerTile(buildTile(Text('a'), containerW), containerW))));
        }
      }
      boardRow.add(Row(
        children: rowsChildren,
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey<int>(i),
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
      text = buildInnerTile(RichText(
        text: TextSpan(
            text: "\u2691",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        textAlign: TextAlign.center,
      ), size);
    }

    Widget innerTile = Container(
      padding: EdgeInsets.all(1.0),
      margin: EdgeInsets.all(2.0),
      height: 20.0,
      width: 20.0,
      color: Colors.grey[350],
      child: text,
    );

    return buildTile(innerTile, size);
  }
}