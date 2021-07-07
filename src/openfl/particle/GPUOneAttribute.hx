package openfl.particle;

/**
 * 单个数值
 */
 class GPUOneAttribute implements GPUAttribute {
	public static function create(value:Float):GPUAttribute {
		return new GPUOneAttribute(value);
	}

	public var value:Float;

	public function new(value:Float) {
		this.value = value;
	}

	public var type(get, never):String;

	function get_type():String {
		return "one";
	}

	public function getValue():Float {
		return value;
	}
}
