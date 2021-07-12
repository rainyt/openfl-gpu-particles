package openfl.particle.data;


interface GPUAttribute {
	public var type(get, never):String;

	public function getValue():Float;

	public function copy():GPUAttribute;
}
