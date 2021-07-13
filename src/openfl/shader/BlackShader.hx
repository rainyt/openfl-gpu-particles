package openfl.shader;

import glsl.GLSL.texture2D;
import VectorMath;

/**
 * 黑底着色器，会使整个粒子不透明的区域变为黑色
 */
class BlackShader extends GPUParticleShader {
	@:uniform public var bitmap2:glsl.Sampler2D;

	override function fragment() {
		super.fragment();
		if (this.color.a != 0) {
			this.gl_FragColor = colorv;
		}
		var mulcolor:Vec4 = texture2D(bitmap2, gl_openfl_TextureCoordv);
		var mulmax:Float = (color.r + color.g + color.b) / 3 + (mulcolor.r + mulcolor.g + mulcolor.b) / 3 - 2 * (1 - outlife);
		mulmax = max(0,mulmax);
		this.gl_FragColor = gl_FragColor * mulmax * gl_FragColor.a * lifeAlpha;
		// this.gl_FragColor = mulcolor;
		
	}
}
