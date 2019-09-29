import 'package:flutter/material.dart';

enum TileState { covered, blown, open, flagged, revealed }

///* use index +1 for difficulty multiplier
enum Difficulty { HARD, MEDIUM, EASY  }

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
  final int rows = 8;
  final int cols = 8;
  final int numOfMines = 8 + (8 * (1.0 / (difficulty.index + 1.0))).floor();

  List<List<TileState>> uiState;

  void resetBoard() {
    uiState = List<List<TileState>>.generate(rows, (row) {
      return List<TileState>.filled(cols, TileState.covered);
    });
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
              child: Listener(
                  child: Container(
                width: containerW,
                height: containerW,
                margin: EdgeInsets.all(2.0),
                color: Colors.grey,
              ))));
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
