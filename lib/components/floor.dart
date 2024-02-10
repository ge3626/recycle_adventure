import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/components/background_tile.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/enemies/bat.dart';
import 'package:pixel_adventure/components/enemies/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/enemies/cucumber.dart';
import 'package:pixel_adventure/components/enemies/slime.dart';
import 'package:pixel_adventure/components/enemies/trunk.dart';
import 'package:pixel_adventure/components/enemies/whale.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Floor extends World with HasGameRef<PixelAdventure> {
  final String floorName;
  final Player player;
  Floor({required this.floorName, required this.player});
  late TiledComponent floor;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    floor = await TiledComponent.load('$floorName.tmx', Vector2.all(16));

    add(floor);

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = floor.tileMap.getLayer('Background');

    const tileSize = 64;
    final numOfTilesY = (game.size.y / tileSize).floor();
    final numOfTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      //Fills the entire background with tiles
      for (double y = 0; y < numOfTilesY + 1; y++) {
        for (double x = 0; x < numOfTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Gray', //The name of a tile
            position: Vector2(x * tileSize - tileSize, y * tileSize - tileSize),
          );
          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    //adding spawn points
    final spawnPointsLayer = floor.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              fruit: spawnPoint.name,
            );
            add(fruit);
            break;
          case 'Saw':
            final saw = Saw(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
              isVertical: spawnPoint.properties.getValue('isVertical'),
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
            break;
          case 'Chicken':
            final chicken = Chicken(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(chicken);
            break;
          case 'Slime':
            final slime = Slime(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(slime);
            break;
          case 'Bat':
            final bat = Bat(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(bat);
            break;
          case 'Trunk':
            final trunk = Trunk(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(trunk);
            break;
          case 'Cucumber':
            final cucumber = Cucumber(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(cucumber);
            break;
          case 'Whale':
            final whale = Whale(
              position: Vector2(spawnPoint.x, spawnPoint.y + 17),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offsetPositive: spawnPoint.properties.getValue('offsetPositive'),
              offsetNegative: spawnPoint.properties.getValue('offsetNegative'),
            );
            add(whale);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    //adding collisions
    final collisionsLayer = floor.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
