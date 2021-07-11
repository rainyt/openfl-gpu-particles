package openfl.particle.data;

class GPUOneTweenAttribute extends GPUTweenAttribute {
	public function pushAttribute(weight:Float, attribute:GPUAttribute) {
		this.attributes.push(new GPUOneTweenChildAttribute(weight, attribute));
	}
}

class GPUOneTweenChildAttribute extends GPUWeightTweenAttribute {
	public var attribute:GPUAttribute;

	public function new(weight:Float, attribute:GPUAttribute) {
		super(weight);
		this.attribute = attribute;
	}
}
