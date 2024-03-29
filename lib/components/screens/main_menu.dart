import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycle_adventure/components/screens/game_play.dart';
import 'package:recycle_adventure/components/screens/option_menu.dart';
import 'package:recycle_adventure/main.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Menu/main_menu.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Text(
                  'Recycle Adventure',
                  style:
                      GoogleFonts.bungeeInlineTextTheme().bodyLarge?.copyWith(
                    fontSize: 50.5,
                    shadows: [
                      const Shadow(
                        blurRadius: 20.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GamePlay(),
                      ),
                    );
                    gameRef.playBackgroundMusic(
                        gameRef.floorNames[gameRef.currentFloorIndex]);
                  },
                  child: const Text('Play'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const OptionMenu(),
                      ),
                    );
                  },
                  child: const Text('Options'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
