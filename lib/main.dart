import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart'; // Redux Sync calls
import 'package:redux_thunk/redux_thunk.dart';     // Redux Async calls
import 'dart:async';
import 'dart:convert';   // to convert Response object to Map object
import 'package:http/http.dart' as http;

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
  String _quote;
  String _author;

  int get counter => _counter;
  String get quote => _quote;
  String get author => _author;

  AppState(this._counter, this._quote, this._author);
}

// Sync Action
enum Action {
  IncrementAction
}

// The object which will be used by Async, ThunkAction, to send Sync Action
// Async -> ThunkAction -> Sync
class UpdateQuoteAction {
  String _quote;
  String _author;

  String get quote => this._quote;
  String get author => this._author;

  UpdateQuoteAction(this._quote, this._author);
}

// ThunkAction
ThunkAction<AppState> getRandomQuote = (Store<AppState> store) async {
  debugPrint("\nIn ThunkAction11");

  http.Response response = await http.get(
    Uri.encodeFull('http://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1'),
  );

  debugPrint("\nGot response");
  debugPrint(response.body);

  List<dynamic> result = json.decode(response.body);

  // This is to remove the <p></p> html tag received. This code is not crucial.
  String quote = result[0]['content'].replaceAll(new RegExp('[(<p>)(</p>)]'), '').replaceAll(new RegExp('&#8217;'),'\'');
  String author = result[0]['title'];

  store.dispatch(
      new UpdateQuoteAction(
          quote,
          author
      )
  );
};

// Reducer
AppState reducer(AppState prev, dynamic action) 
{

  if (action == Action.IncrementAction) {

    debugPrint("\nReducer: Action.IncrementAction");

    AppState newAppState = new AppState(prev.counter + 1, prev.quote, prev.author);

    return newAppState;

  } else if (action is UpdateQuoteAction) {

    debugPrint("\nReducer: UpdateQuoteAction");

    AppState newAppState = new AppState(prev.counter, action.quote, action.author);

    return newAppState;

  } 

  // default return previous state
  return prev;

}

// store that hold our current appstate
// This can be done from our Main also.
final store = new Store<AppState>(
  reducer,
  initialState: new AppState(0, "", ""),
  middleware: [thunkMiddleware]
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

            // UI-View Connector: display random quote and its author
            StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (_, state) {
                return new Text(
                    ' ${state.quote} \n -${state.author}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20.0
                  ),
                );
              },
            ),

            // UI-Action connector: generate quote button
            StoreConnector<AppState, GenerateQuote>(
              converter: (store) => () => store.dispatch(getRandomQuote),
              builder: (_, generateQuoteCallback) {
                return new FlatButton(
                  color: Colors.lightBlue,
                    onPressed: generateQuoteCallback,
                    child: new Text("generate random quote")
                );
              },
            )

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
typedef void GenerateQuote(); // This is async.

// NOTES:
// Error observed and solution
// ----------------------------
// Http connection problem:
//   The Emulator was not able to connect, switch to real hardware.
//   The app was getting <!DOCTYPE html> ...
//   The internet was specified as Living-Gast and thus it was redirect to login page.
//   Connected via eduroam and it is working.

