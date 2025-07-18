import 'dart:async';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// buat refresh table setelah add data
// buat menu bar di kiri ttp ad ketika add data

void main() {
  runApp(const Warehouse());
}

class Warehouse extends StatelessWidget {
  const Warehouse({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Warehouse',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 55, 100, 197)),
          useMaterial3: true,
        ),
        home: const Login(title: 'Login'),
      )
    );
  }
}

class MyAppState extends ChangeNotifier {
  // variable used in the website for every page
  var current = WordPair(' ', ' ');
  
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[]; // list

  void toggleFavourites(){
    if (favorites.contains(current)){
      favorites.remove(current);
    }else {
      favorites.add(current);
    }
    notifyListeners();
  }

  var current2 = WordPair('first', 'second');

  int counter = 0;

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _InputDataKey2 = GlobalKey<FormState>();
  TextEditingController objectName = TextEditingController();
  TextEditingController objectClass = TextEditingController();
  TextEditingController objectQuantity = TextEditingController();

  var objectsName = <String>[]; // list
  var objectsClass = <String>[]; // list
  var objectsQuantity = []; // list

  void addNewData (){
    objectsName.add(objectName.text);
    objectsClass.add(objectClass.text);
    objectsQuantity.add(int.parse(objectQuantity.text));
  }

  void clearAddData(){
    objectName.clear();
    objectClass.clear();
    objectQuantity.clear();
  }
}

class Login extends StatefulWidget {
  const Login({super.key, required this.title});

  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  Widget build(BuildContext context) {
  var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: appState._formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: appState.emailController,
                  decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
            ),
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: appState.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (appState._formKey.currentState!.validate()) {
                          if (appState.emailController.text == "test" &&
                                        appState.passwordController.text == "test") {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid Credentials')),
                              );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill input')),
                          );
                        }
                      },
                    child: const Text('Submit'),
                  ),
                ),
            ),
            ],
          ),
        ),
      ), 
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = ReportPage();
        break;
      case 3:
        page = AddData(title: 'Input Form',);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, // -> true to expand the navigation bar
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.report),
                      label: Text('Report'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.add_circle),
                      label: Text('Form'),
                    ),
                  ],
                  selectedIndex: selectedIndex, //-> to select default menu when start
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourites();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  appState.counter++;
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class ReportPage extends StatefulWidget{
  @override
  State<ReportPage> createState() => _ReportPage();
}

class _ReportPage extends State<ReportPage> {
  //auto refresh
  Timer? _timer;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _counter++; // Or refresh your data here
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to avoid memory leaks
    super.dispose();
  }

  //build the table
  @override
  Widget build(BuildContext context) {
  var appState = context.watch<MyAppState>();
    return Scaffold(
      body: Form(
        child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Padding(
                padding:
                 const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                 child: Row(
                    children: [
                      Padding(
                        padding: 
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                        child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddData(title: 'Input Data',
                              ),
                            ),
                          );
                        },
                      child: const Text('Add Data'),
                      ),
                    ),
                    // -- Buat tambahan tombol --
                    // Padding(
                    //   padding:
                    //   const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                    //   child: Center(
                    //       child: ElevatedButton(
                    //         onPressed: (){
                    //           Navigator.push(
                    //             //ada perubahan
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => AddData(title: 'Input Data',
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         child: const Text('refresh'),
                    //       ),
                    //   ),
                    // ),
                  ],
                 ),
              ),
              DataTable(
                columns: [
                  DataColumn(
                    label: Expanded (
                      child: Text ('Name',
                        style: TextStyle(fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded (
                      child: Text ('Class',
                        style: TextStyle(fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded (
                      child: Text ('Quantity',
                        style: TextStyle(fontStyle: FontStyle.italic
                        ),
                      ),
                    ),
                  ),
                ],
                rows: [
                  for (var i = 0; i <= appState.objectsName.length-1; i++)
                    DataRow(
                    cells: <DataCell>[
                      DataCell(Text(appState.objectsName[i])),
                      DataCell(Text(appState.objectsClass[i])),
                      DataCell(Text('${appState.objectsQuantity[i]}')),
                    ]
                  ) 
                ],
                // Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Text('${appState.objectName.text}'),
                //   ),
                //   Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Text('${appState.objectClass.text}'),
                //   ),
                //   Padding(
                //     padding: const EdgeInsets.all(20),
                //     child: Text('${appState.objectQuantity.text}'),
                //   ),
              ),
            ],
          ),
        ),
      ),
    );throw UnimplementedError();
  }
}

class AddData extends StatefulWidget {
  const AddData ({super.key, required this.title});
  final String title;
  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  @override
  Widget build (BuildContext context){
  var appState = context.watch<MyAppState>();
      return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: appState._InputDataKey2,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: 
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: appState.objectName,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Item Name"),
                      validator: (String? value){
                        if (value == null || value.isEmpty) {
                            return 'Please fill the field';
                          }
                        return null;
                      },
                    ),
                ),
                Padding(
                  padding: 
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: appState.objectClass,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Class Item"),
                      validator: (String? value){
                        if (value == null || value.isEmpty) {
                            return 'Please fill the field';
                          }
                        return null;
                      },
                    ),
                ),
                Padding(
                  padding: 
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      controller: appState.objectQuantity,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: "Quantity Item"),
                      validator: (String? value){
                        if (value == null || value.isEmpty) {
                            return 'Please fill the field';
                          }
                        return null;
                      },
                    ),
                ),
                Padding(
                  padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (appState._InputDataKey2.currentState!.validate()){
                              appState.addNewData();
                              // Navigator.push(
                              // context,
                              // MaterialPageRoute(builder: (context) => ReportPage()),
                              // // ).then((value) => setState(() {})
                              // );
                              Navigator.pop(context, true);
                              appState.clearAddData();
                            }
                          },
                        child: const Text('Submit'),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

// class refreshPage extends StatelessWidget{
//   @override
//   Widget build (BuildContext context){
//     return 
//     Navigator.pop(context, true);
//   }
// }

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //for color
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary, backgroundColor: theme.colorScheme.secondary);

    return Card(
      color: theme.colorScheme.primary,
      //color: theme.colorScheme.fromSeed(seedColor: Colors.green),
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Text(pair.asLowerCase, style: style, semanticsLabel: "${pair.first} ${pair.second}",),
      ),
    );
  }
}