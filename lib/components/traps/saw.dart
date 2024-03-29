import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:recycle_adventure/components/player.dart';
import 'package:recycle_adventure/recycle_adventure.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<RecycleAdventure> {
  final bool isVertical;
  final double offsetNegative;
  final double offsetPositive;
  final int initialDirection;
  Saw({
    //default settings
    this.isVertical = false,
    this.offsetNegative = 0,
    this.offsetPositive = 0,
    this.initialDirection = 0,
    super.position,
    super.size,
  });
  late final Player player;

  static const double sawSpeed = 0.05;
  static const moveSpeed = 50;
  static const tileSize = 16;
  late int moveDirection;
  double rangeNegative = 0;
  double rangePositive = 0;

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    player = game.player;
    moveDirection = initialDirection;

    add(CircleHitbox());

    //Sets movement range.
    if (isVertical) {
      //vertical movement
      rangeNegative = position.y - offsetNegative * tileSize;
      rangePositive = position.y + offsetPositive * tileSize;
    } else {
      //horizontal movement
      rangeNegative = position.x - offsetNegative * tileSize;
      rangePositive = position.x + offsetPositive * tileSize;
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawSpeed,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    //Makes saw move.
    if (isVertical) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePositive) {
      moveDirection = -1;
    } else if (position.y <= rangeNegative) {
      moveDirection = 1;
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePositive) {
      moveDirection = -1;
    } else if (position.x <= rangeNegative) {
      moveDirection = 1;
    }
    position.x += moveDirection * moveSpeed * dt;
  }

  void collidedWithPlayer() {
    if (game.isSoundEffectOn) {
      FlameAudio.play('enemyKilled.wav', volume: game.soundEffectVolume);
    }
    game.health--;
    player.respawn();
  }
}
