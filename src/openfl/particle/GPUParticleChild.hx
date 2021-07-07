package openfl.particle;

import VectorMath;

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
}
