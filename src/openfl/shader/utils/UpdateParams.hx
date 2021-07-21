package openfl.shader.utils;

import openfl.particle.data.GPUParticleChild;

class UpdateParams {
	public var childs:Array<GPUParticleChild> = [];

	public function new() {}

	public function push(child:GPUParticleChild):Void {
		childs.push(child);
	}

}
