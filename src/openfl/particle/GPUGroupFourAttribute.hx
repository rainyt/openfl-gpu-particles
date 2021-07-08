package openfl.particle;

class GPUGroupFourAttribute {
    /**
	 * 初始化时使用的参数
	 */
	public var start:GPUFourAttribute;

	/**
	 * 结束时使用的参数
	 */
	public var end:GPUFourAttribute;

	public function new(start:GPUFourAttribute, end:GPUFourAttribute) {
		this.start = start;
		this.end = end;
	}

	public function get_type():String {
		return "four-group";
	}

	public var type(get, never):String;
}