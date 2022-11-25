import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}



enum City {
  london,
  paris,
  rome,
  newyork,
}

typedef WheaterEmoji = String;

Future<WheaterEmoji> getWheaterEmoji(City city) {
   return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.london: '🌤️',
      City.paris: '🌧️',
      City.rome: '🌦️',
      City.newyork: '🌩️',
    }[city]!,
  );
}

// UI writes and reads from this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
  );

  const unknownWeatherEmoji = '❓';

// UI reads this
  final weatherProvider = FutureProvider<WheaterEmoji>((ref){
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWheaterEmoji(city);
    }else{
      return unknownWeatherEmoji;
    }
  });

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);


        return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Weather',
          ),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(data,style: const TextStyle(fontSize:40),),
            loading: () => const Padding(
              padding:  EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => const Text('Error 😢'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString()
                    ),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () =>
                      ref.read(currentCityProvider.notifier).state = city,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}