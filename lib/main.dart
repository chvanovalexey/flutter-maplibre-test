import 'package:flutter/material.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'new_map_page.dart';
import 'styled_map_page.dart';

void main() async {  
  // Обязательно для инициализации Firebase  
  WidgetsFlutterBinding.ensureInitialized();  
  
  // Инициализация Firebase с конфигурационными данными  
  await Firebase.initializeApp(  
    options: FirebaseOptions(  
      apiKey: "AIzaSyDOFD7rsFUIDfkKhWsWkOFirjWyWi_jaIU",  
      authDomain: "flutter-maplibre-test.firebaseapp.com",  
      projectId: "flutter-maplibre-test",  
      storageBucket: "flutter-maplibre-test.firebasestorage.app",  
      messagingSenderId: "653816727992",  
      appId: "1:653816727992:web:4247ff5ac19842c6f9e74d",  
    ),  
  );  
  
  runApp(const MyApp());  
}  

class MyApp extends StatelessWidget {  
  const MyApp({super.key});  

  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      title: 'Flutter MapLibre Test',  
      theme: ThemeData(  
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),  
      ),  
      home: const MyHomePage(title: 'Flutter MapLibre Demo'),  
    );  
  }  
}  

class MyHomePage extends StatefulWidget {  
  const MyHomePage({super.key, required this.title});  

  final String title;  

  @override  
  State<MyHomePage> createState() => _MyHomePageState();  
}  

class _MyHomePageState extends State<MyHomePage> {  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,  
        title: Text(widget.title),  
      ),  
      body: Center(  
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Демонстрация MapLibre',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewMapPage()),
                );
              },
              child: const Text('Открыть карту'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StyledMapPage()),
                );
              },
              child: const Text('Открыть стилизованную карту'),
            ),
          ],  
        ),  
      ),  
    );  
  }  
}  

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карта'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          'Здесь будет карта MapLibre',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}  