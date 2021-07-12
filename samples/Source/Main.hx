package;

import openfl.particle.events.ParticleEvent;
import haxe.Json;
import openfl.events.MouseEvent;
import openfl.particle.GPUParticleSprite;
import openfl.particle.data.GPURandomTwoAttribute;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.utils.Assets;

using openfl.particle.Tools;

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
		Assets.loadBitmapData("assets/caidai.png").onComplete(function(texture) {
			// 创建一个粒子对象
			var gpuSystem:GPUParticleSprite = null;
			for (i in 0...0) {
				gpuSystem = new GPUParticleSprite();
				// gpuSystem.scaleX = 0.1;
				// gpuSystem.scaleY = 0.1;
				this.addChild(gpuSystem);
				// 设置粒子动态更新
				gpuSystem.dynamicEmitPoint = false;
				// 设置粒子的发生方式
				gpuSystem.emitMode = Point;
				// 设置粒子的纹理
				gpuSystem.texture = texture;
				// 设置粒子数量
				gpuSystem.counts = 50;
				// 设置是否循环
				gpuSystem.duration = -1;
				// 设置粒子方向范围
				gpuSystem.velocity.x.asOneAttribute().value = 100;
				gpuSystem.velocity.y.asOneAttribute().value = 100;
				// 设置粒子重力
				gpuSystem.gravity.x.asOneAttribute().value = 200;
				gpuSystem.gravity.y.asOneAttribute().value = 200;
				// 设置切向
				gpuSystem.tangential.x.asOneAttribute().value = 200;
				// 设置粒子的生命力
				gpuSystem.life = 1;
				// 设置粒子的初始点范围
				gpuSystem.widthRange = 50;
				gpuSystem.heightRange = 50;
				// 设置粒子的缩放系数
				var startrandom = new GPURandomTwoAttribute(1, 2);
				var random = new GPURandomTwoAttribute(0., 0.1);
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
				if (gpuSystem != null)
					gpuSystem.startDrag();
			});

			stage.addEventListener(MouseEvent.MOUSE_UP, function(e) {
				this.stopDrag();
			});

			// JSON粒子DEMO
			Assets.loadText("assets/caidai.json").onComplete(function(data) {
				// Create JSON Particle
				var jsonParticle = GPUParticleSprite.fromJson(Json.parse(data), texture);
				this.addChild(jsonParticle);
				jsonParticle.x = stage.stageWidth / 2;
				jsonParticle.y = stage.stageHeight / 2;
				jsonParticle.start();

				trace("isLoop", jsonParticle.loop, jsonParticle.duration);

				// Stop event
				jsonParticle.addEventListener(ParticleEvent.STOP, function(data) {
					trace("stop!");
				});
			});
		});
	}
}
