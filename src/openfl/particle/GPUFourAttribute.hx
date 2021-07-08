package openfl.particle;

class GPUFourAttribute {
	public var x:GPUAttribute = new GPUOneAttribute(1);

	public var y:GPUAttribute = new GPUOneAttribute(1);

	public var z:GPUAttribute = new GPUOneAttribute(1);

	public var w:GPUAttribute = new GPUOneAttribute(1);

	public function new(x:Dynamic = null, y:Dynamic = null, z:Dynamic = null, w:Dynamic = null) {
		if (x != null)
			this.x = toAttribute(x);
		if (y != null)
			this.y = toAttribute(y);
		if (w != null)
			this.w = toAttribute(w);
		if (z != null)
			this.z = toAttribute(z);
	}

	private function toAttribute(value:Dynamic):GPUAttribute {
		if (Std.isOfType(value, GPUAttribute))
			return value;
		return new GPUOneAttribute(value);
	}
}
