package openfl.particle.data;

class GPUFourTweenAttribute extends GPUTweenAttribute {
	public function pushAttribute(weight:Float, attribute:GPUFourAttribute) {
		this.attributes.push(new GPUFourTweenChildAttribute(weight, attribute));
	}
}

class GPUFourTweenChildAttribute extends GPUWeightTweenAttribute {
	public var attribute:GPUFourAttribute;

	public function new(weight:Float, attribute:GPUFourAttribute) {
		super(weight);
		this.attribute = attribute;
	}
}
