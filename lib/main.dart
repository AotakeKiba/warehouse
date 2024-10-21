import 'package:flutter/material.dart';

final _formKey = GlobalKey<FormState>();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Warehouse(title: 'Login'),
    );
  }
}

class Warehouse extends StatefulWidget {
  const Warehouse({super.key, required this.title});

  final String title;

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
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
                  controller: passwordController,
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
                      if (_formKey.currentState!.validate()) {
                        // Navigate the user to the Home page
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (emailController.text == "arun@gogosoon.com" &&
                                      passwordController.text == "qazxswedcvfr") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(
                                email: emailController.text,
                              )),
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
            Text(email),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Go back!"),
              ),
            ),
          ],
        ));
  }