import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:recycle_adventure/components/player.dart';
import 'package:recycle_adventure/recycle_adventure.dart';

class Bullet extends SpriteAnimationComponent
    with HasGameRef<RecycleAdventure>, CollisionCallbacks {
  double speed;
  String imagePath;
  int animationAmount;
  bool moveVertically;
  double moveDirection;
  RectangleHitbox hitbox;
  Bullet({
    super.position,
    this.speed = 450,
    this.imagePath = "Bullets/bullet_default.png", //default bullet
    this.animationAmount = 1,
    this.moveVertically = false,
    required this.moveDirection,
    required this.hitbox,
  }) : super(
          size: Vector2(25, 25),
          anchor: Anchor.center,
        );

  late final Player player;

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    priority = 4;
    player = game.player;

    updateBulletDirection();

    add(hitbox);

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(imagePath),
      SpriteAnimationData.sequenced(
        amount: animationAmount,
        stepTime: 0.2,
        textureSize: Vector2(16, 16),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    movement(dt);
    super.update(dt);
  }

  void movement(dt) {
    if (moveVertically) {
      position.y -= speed * dt;
    } else {
      position.x += moveDirection * speed * dt;
    }

    if (position.y < -game.size.y ||
        position.x < 0 ||
        position.x > game.size.x) {
      removeFromParent();
    }
  }

  void updateBulletDirection() {
    if (moveDirection == 1) {
      flipHorizontallyAroundCenter();
    }
    if (moveVertically) {
      angle = -90; //TODO
    }
  }
}
