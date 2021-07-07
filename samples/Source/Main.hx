package;

import openfl.events.MouseEvent;
import openfl.particle.GPUParticleSprite;
import openfl.particle.GPURandomTowAttribute;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;

/**
 * SpineDemo
 */
class Main extends Sprite {
	public function new() {
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, onInit);
	}

	public function onInit(e:Event):Void {
		stage.color = 0x0;
		Assets.loadBitmapData("assets/texture.png").onComplete(function(texture) {
			// 创建一个粒子对象
			var gpuSystem:GPUParticleSprite = null;
			for (i in 0...10) {
				gpuSystem = new GPUParticleSprite();
				// gpuSystem.scaleX = 0.1;
				// gpuSystem.scaleY = 0.1;
				this.addChild(gpuSystem);
				// 设置粒子动态更新
				gpuSystem.dynamicEmitPoint = i == 9;
				// 设置粒子的发生方式
				gpuSystem.emitMode = Point;
				// 设置粒子的纹理
				gpuSystem.texture = texture;
				// 设置粒子数量
				gpuSystem.counts = 50;
				// 设置是否循环
				gpuSystem.loop = true;
				// 设置粒子方向范围
				gpuSystem.velocity.x = 100;
				gpuSystem.velocity.y = 100;
				// 设置粒子重力
				gpuSystem.gravity.x = 200;
				gpuSystem.gravity.y = 200;
				// 设置粒子的生命力
				gpuSystem.life = 1;
				// 设置粒子的初始点范围
				gpuSystem.widthRange = 50;
				gpuSystem.heightRange = 50;
				// 设置粒子的缩放系数
				var startrandom = new GPURandomTowAttribute(1, 2);
				var random = new GPURandomTowAttribute(0., 0.1);
				gpuSystem.scaleXAttribute.start = startrandom;
				gpuSystem.scaleYAttribute.start = startrandom;
				gpuSystem.scaleXAttribute.end = random;
				gpuSystem.scaleYAttribute.end = random;
				// gpuSystem.mouseEnabled = false;

				gpuSystem.x = Std.random(Std.int(stage.stageWidth));
				gpuSystem.y = Std.random(Std.int(stage.stageHeight));
				// gpuSystem.x = getStageWidth() / 2;
				// gpuSystem.y = getStageHeight() / 2;
				// 开始发射
				gpuSystem.start();
			}

			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e) {
				gpuSystem.startDrag();
			});

			stage.addEventListener(MouseEvent.MOUSE_UP, function(e) {
				this.stopDrag();
			});
		});
	}
}
