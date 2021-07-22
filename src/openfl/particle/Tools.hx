package openfl.particle;

import openfl.particle.data.*;

class Tools {
	public static function asOneAttribute(value:GPUAttribute):GPUOneAttribute {
		return cast value;
	}

	public static function asRandomTwoAttribute(value:GPUAttribute):GPURandomTwoAttribute {
		return cast value;
	}
}
