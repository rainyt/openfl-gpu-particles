package openfl.particle.data;

/**
 * GPU属性组
 */
class GPUGroupAttribute {
	/**
	 * 初始化时使用的参数
	 */
	public var start:GPUAttribute;

	/**
	 * 过渡参数
	 */
	public var tween:GPUOneTweenAttribute = new GPUOneTweenAttribute();

	/**
	 * 结束时使用的参数
	 */
	public var end:GPUAttribute;

	public function new(start:GPUAttribute, end:GPUAttribute) {
		this.start = start;
		this.end = end;
	}

	public function get_type():String {
		return "group";
	}

	public var type(get, never):String;

	/**
	 * 存在过渡值
	 * @return Bool
	 */
	public function hasTween():Bool {
		return tween.attributes.length > 0;
	}
}
