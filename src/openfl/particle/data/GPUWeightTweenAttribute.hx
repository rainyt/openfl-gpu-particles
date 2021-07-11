package openfl.particle.data;

import openfl.particle.data.GPUOneTweenAttribute.GPUOneTweenChildAttribute;
import openfl.particle.data.GPUFourTweenAttribute.GPUFourTweenChildAttribute;

class GPUWeightTweenAttribute {
	public var weight:Float;

	/**
	 * 生命周期比例
	 */
	public var aliveTimeScale:Float;

	public function new(weight:Float) {
		this.weight = weight;
	}

	public function asFourAttribute():GPUFourTweenChildAttribute {
		return cast this;
	}

	public function asOneAttribute():GPUOneTweenChildAttribute {
		return cast this;
	}
}
