package openfl.particle.data;

import VectorMath;

@:access(openfl.particle.GPUParticleSprite)
class GPUParticleChild {
	public var id:Int;

	/**
	 * 生命周期
	 */
	public var life:Float = 0;

	/**
	 * 随机粒子
	 */
	public var random:Float = 0;

	/**
	 * 上一次生命周期
	 */
	private var lastLife:Float = 0;

	private var _init:Bool = false;

	public var sprite:GPUParticleSprite;

	public function new(sprite:GPUParticleSprite, id:Int) {
		this.id = id;
		this.sprite = sprite;
	}

	/**
	 * 是否可以重置
	 * @return Bool
	 */
	public function onReset():Bool {
		var nowtime:Float = sprite.time - life * random;
		if (_init) {
			var aliveTime:Float = mod(nowtime, life);
			aliveTime = aliveTime * step(0, nowtime);
			if (aliveTime > 0 && lastLife >= aliveTime) {
				lastLife = aliveTime;
				return true;
			}
			lastLife = aliveTime;
		} else if (nowtime > 0) {
			_init = true;
			return true;
		}
		return false;
	}

	public function reset():Void {
		var r = Math.random();
		var vx = 0.;
		var vy = 0.;
		var ax = 0.;
		var ay = 0.;
		var tx = 0.;
		var ty = 0.;
		var angle = 0.;
		// 点与中心的角度
		var posAngle = 0.;
		var sx = Math.random() * sprite.widthRange * 2 - sprite.widthRange;
		var sy = Math.random() * sprite.heightRange * 2 - sprite.heightRange;
		posAngle = -Math.atan2((sy - 0), (sx - 0));
		var posAngle2 = Math.atan2((sx - 0), (sy - 0));
		// posAngle = -45 * 3.14 / 180;
		switch (sprite.emitMode) {
			case Point:
				angle = sprite.emitRotation.getValue() * Math.PI / 180;
				vx = sprite.velocity.x.getValue();
				vy = sprite.velocity.y.getValue();
				ax = sprite.acceleration.x.getValue();
				ay = sprite.acceleration.y.getValue();
				tx = sprite.tangential.x.getValue();
				ty = sprite.tangential.y.getValue();
			default:
				angle = sprite.emitRotation.getValue() * Math.PI / 180;
				vx = sprite.velocity.x.getValue();
				vy = sprite.velocity.y.getValue();
				ax = sprite.acceleration.x.getValue();
				ay = sprite.acceleration.y.getValue();
		}

		// 方向力
		var vx1:Float = Math.cos(angle) * vx + Math.sin(angle) * vy;
		var vy1:Float = Math.cos(angle) * vy - Math.sin(angle) * vx;
		vx = vx1;
		vy = vy1;

		// 加速力
		var ax1:Float = Math.cos(posAngle) * ax + Math.sin(posAngle) * ay;
		var ay1:Float = Math.cos(posAngle) * ay - Math.sin(posAngle) * ax;
		ax = ax1;
		ay = ay1;

		// 切向力
		var tx1:Float = Math.cos(posAngle2) * tx + Math.sin(posAngle2) * ty;
		var ty1:Float = Math.cos(posAngle2) * ty - Math.sin(posAngle2) * tx;
		tx = tx1;
		ty = ty1;

		var gx = sprite.gravity.x.getValue();
		var gy = sprite.gravity.y.getValue();

		var scaleXstart:Float = sprite.scaleXAttribute.start.getValue();
		var scaleYstart:Float = sprite.scaleYAttribute.start == sprite.scaleXAttribute.start ? scaleXstart : sprite.scaleYAttribute.start.getValue();
		var scaleXend:Float = sprite.scaleXAttribute.end.getValue();
		var scaleYend:Float = sprite.scaleYAttribute.end == sprite.scaleXAttribute.end ? scaleXend : sprite.scaleYAttribute.end.getValue();

		var startRotaion:Float = sprite.rotaionAttribute.start.getValue();
		var endRotaion:Float = sprite.rotaionAttribute.end.getValue();

		// 生命+生命方差实现
		var rlife = sprite.life + Math.random() * sprite.lifeVariance;

		this.life = rlife;
		this.random = r;

		var startColor1 = sprite.colorAttribute.start.x.getValue();
		var startColor2 = sprite.colorAttribute.start.y.getValue();
		var startColor3 = sprite.colorAttribute.start.z.getValue();
		var startColor4 = sprite.colorAttribute.start.w.getValue();

		var endColor1 = sprite.colorAttribute.end.x.getValue();
		var endColor2 = sprite.colorAttribute.end.y.getValue();
		var endColor3 = sprite.colorAttribute.end.z.getValue();
		var endColor4 = sprite.colorAttribute.end.w.getValue();

		var index1 = id * 6;
		var index2 = id * 12;
		var index3 = id * 18;
		var index4 = id * 24;

		for (i in 0...6) {
			// 颜色过渡
			sprite._shader.a_startColor.value[index4] = (startColor1);
			sprite._shader.a_startColor.value[index4 + 1] = (startColor2);
			sprite._shader.a_startColor.value[index4 + 2] = (startColor3);
			sprite._shader.a_startColor.value[index4 + 3] = (startColor4);
			sprite._shader.a_endColor.value[index4] = (endColor1);
			sprite._shader.a_endColor.value[index4 + 1] = (endColor2);
			sprite._shader.a_endColor.value[index4 + 2] = (endColor3);
			sprite._shader.a_endColor.value[index4 + 3] = (endColor4);
			// 角度
			sprite._shader.a_rota.value[index2] = (startRotaion);
			sprite._shader.a_rota.value[index2 + 1] = (endRotaion);
			// 随机值
			sprite._shader.a_random.value[index1] = (r);
			// 移动向量
			sprite._shader.a_velocity.value[index2] = (vx);
			sprite._shader.a_velocity.value[index2 + 1] = (vy);
			// 重力以及切向加速力
			sprite._shader.a_gravityxAndTangential.value[index4] = gx;
			sprite._shader.a_gravityxAndTangential.value[index4 + 1] = gy;
			sprite._shader.a_gravityxAndTangential.value[index4 + 2] = tx;
			sprite._shader.a_gravityxAndTangential.value[index4 + 3] = ty;
			// 加速力
			sprite._shader.a_acceleration.value[index2] = (ax);
			sprite._shader.a_acceleration.value[index2 + 1] = (ay);
			// 粒子生存时间
			sprite._shader.a_life.value[index1] = (rlife);
			// 初始化位置
			sprite._shader.a_pos.value[index2] = (sx);
			sprite._shader.a_pos.value[index2 + 1] = (sy);
			// 缩放比例
			sprite._shader.a_scaleXXYY.value[index4] = (scaleXstart);
			sprite._shader.a_scaleXXYY.value[index4 + 1] = (scaleXend);
			sprite._shader.a_scaleXXYY.value[index4 + 2] = (scaleYstart);
			sprite._shader.a_scaleXXYY.value[index4 + 3] = (scaleYend);
			// 动态点
			if (sprite.dynamicEmitPoint) {
				sprite._shader.a_dynamicPos.value[index3] = (sprite.x);
				sprite._shader.a_dynamicPos.value[index3 + 1] = (sprite.y);
				sprite._shader.a_dynamicPos.value[index3 + 2] = (1);
			} else {
				sprite._shader.a_dynamicPos.value[index3] = (0);
				sprite._shader.a_dynamicPos.value[index3 + 1] = (0);
				sprite._shader.a_dynamicPos.value[index3 + 2] = (0);
			}
			index1++;
			index2 += 2;
			index3 += 3;
			index4 += 4;
		}
	}
}
