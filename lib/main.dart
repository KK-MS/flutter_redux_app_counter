import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart'; // Redux Sync calls
import 'dart:convert';   // to convert Response object to Map object

/*
 * As per blog
 * https://medium.com/flutterpub/flutter-redux-thunk-27c2f2b80a3b
 * Git Source: https://github.com/iamjackslayer/Flutter-Redux-Thunk-on-Medium/blob/master/pubspec.yaml
 *
 */

// AppState: Called as 'state', as it contains the current state values and the
// function or reducers which will predict next state
class AppState {
  int _counter;

  int get counter => _counter;

  AppState(this._counter);
}

// Sync Action
enum Action {
  IncrementAction
}

// Reducer
AppState reducer(AppState prev, dynamic action) 
{

  if (action == Action.IncrementAction) {

    debugPrint("\nReducer: Action.IncrementAction");

    AppState newAppState = new AppState(prev.counter + 1);

    return newAppState;

  } 

  // default return previous state
  return prev;

}

// store that hold our current appstate
// This can be done from our Main also.
final store = new Store<AppState>(
  reducer,
  initialState: new AppState(0),
);


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    debugPrint("\nMyApp StatelessWidget");
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ), //Material App 
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StoreConnector<AppState, int>(
              converter: (store) => store.state.counter,
              builder: (_, counter) {
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: StoreConnector<AppState, IncrementCounter>(
        converter: (store) => () => store.dispatch(Action.IncrementAction),
        builder: (_, incrementCallback) {
          return new FloatingActionButton(
            onPressed: incrementCallback,
            tooltip: 'Increment',
            child: new Icon(Icons.add),
          );
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

typedef void IncrementCounter(); // This is sync.
