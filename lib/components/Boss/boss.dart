import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:recycle_adventure/components/Boss/bomb.dart';
import 'package:recycle_adventure/components/Boss/drones/drone_spawn_manager.dart';
import 'package:recycle_adventure/components/bullet.dart';
import 'package:recycle_adventure/components/player.dart';
import 'package:recycle_adventure/components/widgets/to_ending_button.dart';
import 'package:recycle_adventure/recycle_adventure.dart';

enum State {
  idle,
  left,
  right,
  hit,
  attack1,
  attack2,
  attack3,
  attack4,
  dead,
}

class Boss extends SpriteAnimationGroupComponent
    with HasGameRef<RecycleAdventure>, CollisionCallbacks {
  late Timer _timer;
  late final BombSpawnManager bombSpawnManager;
  late final DroneSpawnManager droneSpawnManager;
  Boss({
    super.position,
    super.size,
    required this.bombSpawnManager,
    required this.droneSpawnManager,
  }) : super() {
    //randomly chooses pattern every second.
    _timer = Timer(1, onTick: _randomlyChoosePattern, repeat: true);
  }

  late final SpriteAnimation _idleSpriteAnimation;
  late final SpriteAnimation _leftSpriteAnimation;
  late final SpriteAnimation _rightSpriteAnimation;
  late final SpriteAnimation _hitSpriteAnimation;
  late final SpriteAnimation _attack1SpriteAnimation;
  late final SpriteAnimation _attack2SpriteAnimation;
  late final SpriteAnimation _attack3SpriteAnimation;
  late final SpriteAnimation _attack4SpriteAnimation;
  late final SpriteAnimation _deadSpriteAnimation;

  final int maxLives = 120;
  int lives = 120;
  bool dead = false;
  bool isHitOn = false;
  Vector2 velocity = Vector2.zero();
  double directionX = 0;
  double moveSpeed = 80;

  bool onPattern1 = false;
  bool onPattern2 = false;
  bool onPattern3 = false;

  late final Player player;
  late RectangleHitbox hitbox;

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    priority = 3;
    player = game.player;
    player.verticalShootingOn = true;

    _loadSpriteAnimations();

    hitbox = RectangleHitbox(
      position: Vector2(5, 48),
      size: Vector2(88, 10),
    );
    add(hitbox);

    _timer.start();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
    _checkLives();
    if (!dead) {
      _movement(dt);

      if (!onPattern1 && !onPattern2 && !onPattern3 && !isHitOn) {
        _updateState();
      }

      if (onPattern1) {
        _pattern1();
      }
      if (onPattern3) {
        _pattern3();
      }
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.stop();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      game.health--;
      player.respawn();
    }
    if (isHitOn) {
      if (other is Bullet) {
        if (game.isSoundEffectOn) {
          FlameAudio.play('boss-damaged.mp3', volume: game.soundEffectVolume);
        }
        current = State.hit;
        Future.delayed(const Duration(milliseconds: 200), () {
          current = State.idle;
        });
        lives--;
        other.removeFromParent();
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Boss/Machine Operator/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.1,
        textureSize: Vector2.all(96),
      ),
    );
  }

  void _loadSpriteAnimations() {
    _idleSpriteAnimation = _spriteAnimation('Idle', 4);
    _leftSpriteAnimation = _spriteAnimation('Left', 8);
    _rightSpriteAnimation = _spriteAnimation('Right', 8);
    _hitSpriteAnimation = _spriteAnimation('Hurt', 2)..loop = false;
    _attack1SpriteAnimation = _spriteAnimation('Attack1', 8);
    _attack2SpriteAnimation = _spriteAnimation('Attack2', 8);
    _attack3SpriteAnimation = _spriteAnimation('Attack3', 8);
    _attack4SpriteAnimation = _spriteAnimation('Attack4', 6);
    _deadSpriteAnimation = _spriteAnimation('Death', 6)..loop = false;

    animations = {
      State.idle: _idleSpriteAnimation,
      State.left: _leftSpriteAnimation,
      State.right: _rightSpriteAnimation,
      State.hit: _hitSpriteAnimation,
      State.attack1: _attack1SpriteAnimation,
      State.attack2: _attack2SpriteAnimation,
      State.attack3: _attack3SpriteAnimation,
      State.attack4: _attack4SpriteAnimation,
      State.dead: _deadSpriteAnimation,
    };

    current = State.idle;
  }

  void _updateState() {
    if (velocity.x != 0) {
      if (velocity.x > 0) {
        current = State.right;
      } else {
        current = State.left;
      }
    } else {
      current = State.idle;
    }
  }

  void _movement(dt) {
    position.x += velocity.x * dt;
  }

  void _checkLives() {
    if (lives <= 0) {
      if (lives == 0) {
        if (game.isSoundEffectOn) {
          FlameAudio.play('boss-dead.mp3', volume: game.soundEffectVolume);
          lives--;
        }
      }
      dead = true;
      isHitOn = false;
      current = State.dead;
      _timer.stop();
      Future.delayed(const Duration(seconds: 3), () {
        game.numberCleared++;
        game.overlays.add(ToEndingButton.ID);
      });
    }
  }

  void _randomlyChoosePattern() {
    if (!onPattern1 && !onPattern2 && !onPattern3 && !isHitOn) {
      int rd = Random().nextInt(3);

      switch (rd) {
        case 0:
          onPattern1 = true;
          directionX = -1;
          hitbox.size = Vector2(32, 78);
          hitbox.position = Vector2(32, 0);
          _pattern1();
          break;
        case 1:
          onPattern2 = true;
          _pattern2();
          break;
        case 2:
          onPattern3 = true;
          directionX = 1;
          _pattern3();
          break;
      }
    }
  }

  void _pattern1() {
    if (directionX == -1) {
      if (position.x >= -96) {
        current = State.left;
        velocity.x = -1 * 100;
      } else {
        // Change direction after a delay
        velocity.x = 0;
        position = Vector2(-96, 208);
        current = State.attack3;
        Future.delayed(const Duration(seconds: 1), () {
          directionX = 1;
        });
      }
    }

    if (directionX == 1) {
      if (position.x < 432) {
        // Move right
        current = State.attack3;
        velocity.x = 1 * 50;
      } else {
        // Stop and change direction after a delay
        velocity.x = 0;
        Future.delayed(const Duration(seconds: 1), () {
          directionX = -2;
        });
      }
    }

    // Handle movement for directionX == -2
    if (directionX == -2) {
      if (position.x > -96) {
        // Move left
        current = State.attack4;
        velocity.x = -1 * 170;
      } else {
        // Stop, print message, and set flag
        velocity.x = 0;
        position = Vector2(-96, 64);
        Future.delayed(const Duration(seconds: 1), () {
          directionX = 3;
        });
      }
    }

    if (directionX == 3) {
      if (position.x < 272) {
        current = State.right;
        velocity.x = 1 * 120;
      } else {
        velocity.x = 0;
        current = State.idle;

        Future.delayed(const Duration(milliseconds: 500), () {
          hitbox.position = Vector2(5, 48);
          hitbox.size = Vector2(88, 10);
          isHitOn = true;
          onPattern1 = false;
        });
        Future.delayed(const Duration(seconds: 4), () {
          isHitOn = false;
        });
      }
    }
  }

  void _pattern2() {
    current = State.attack1;
    if (!droneSpawnManager.timer.isRunning()) {
      droneSpawnManager.timer.resume();
    }

    //spawns drones for 10 seconds.
    Future.delayed(const Duration(seconds: 10), () {
      droneSpawnManager.timer.stop();
      current = State.idle;
    });

    Future.delayed(const Duration(seconds: 5), () {
      onPattern2 = false;
    });
  }

  void _pattern3() {
    if (directionX == 1) {
      if (position.x < 512) {
        current = State.right;
        velocity.x = 1 * 80;
      } else {
        current = State.attack1;
        velocity.x = 0;
        Future.delayed(const Duration(seconds: 1), () {
          directionX = -1;
        });
      }
    } else if (directionX == -1) {
      if (position.x > 44) {
        current = State.attack2;
        bombSpawnManager.timer.resume();
        bombSpawnManager.droppingPosition = Vector2(position.x + 32, 172);
        velocity.x = -1 * 80;
      } else {
        current = State.attack1;
        bombSpawnManager.timer.stop();
        velocity.x = 0;
        Future.delayed(const Duration(seconds: 1), () {
          directionX = -2;
        });
      }
    }

    if (directionX == -2) {
      if (position.x < 512) {
        current = State.attack2;
        bombSpawnManager.timer.resume();
        bombSpawnManager.droppingPosition = Vector2(position.x + 32, 172);
        velocity.x = 1 * 80;
      } else {
        current = State.idle;
        bombSpawnManager.timer.stop();
        velocity.x = 0;
        Future.delayed(const Duration(seconds: 1), () {
          directionX = -3;
        });
      }
    }

    if (directionX == -3) {
      if (position.x > 272) {
        current = State.left;
        velocity.x = -1 * 80;
      } else {
        current = State.idle;
        velocity.x = 0;
        position.x = 272;

        Future.delayed(const Duration(milliseconds: 500), () {
          onPattern3 = false;
          isHitOn = true;
        });

        Future.delayed(const Duration(seconds: 4), () {
          isHitOn = false;
        });
      }
    }
  }
}
