import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure/components/Boss/boss.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum State { available, unavailable }

class BossHealthBar extends SpriteGroupComponent
    with HasGameRef<PixelAdventure> {
  final int bossMaxLives;
  final Boss boss;
  BossHealthBar({
    super.position,
    super.size,
    super.priority,
    required this.bossMaxLives,
    required this.boss,
  });

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _loadSprites();
  }

  @override
  void update(double dt) {
    if (boss.lives < bossMaxLives) {
      current = State.unavailable;
    } else {
      current = State.available;
    }
    super.update(dt);
  }

  void _loadSprites() async {
    final availableSprite = await game.loadSprite(
      'HUD/boss healthbar.png',
      srcSize: Vector2(2, 16),
    );

    final unavailableSprite = await game.loadSprite(
      'HUD/boss healthbar_empty.png',
      srcSize: Vector2(2, 16),
    );

    sprites = {
      State.available: availableSprite,
      State.unavailable: unavailableSprite,
    };

    current = State.available;
  }
}