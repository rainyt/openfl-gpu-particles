import VectorMath;

/**
 * 用于测试Shader的运算逻辑
 */
class Test {
	/**
	 * 颜色的过渡值开始1 过程2 过程3 最终4
	 */
	public static var colorlife:Vec4 = vec4(0, 1, 2, 2);

	/**
	 * 颜色值
	 */
	public static var colors:Mat4 = mat4(1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0.5, 1, 1, 1, 0);

	static function main() {
		var ooutlife:Float = 0;
		for (i in 0...10) {
			ooutlife += 0.1;
			// 颜色处理模块
			var allcolorlife:Float = colorlife.x + colorlife.y + colorlife.z + colorlife.w;
			var clife1:Float = colorlife.x / allcolorlife;
			var clife2:Float = (colorlife.x + colorlife.y) / allcolorlife;
			var clife3:Float = (colorlife.x + colorlife.y + colorlife.z) / allcolorlife;
			var clife4:Float = (colorlife.x + colorlife.y + colorlife.z + colorlife.w) / allcolorlife;
			// 如果剩余时间大于过渡时间
			// 计算出开始过渡值
			var startlife:Float = 0;
			var endlife:Float = 0;
			var startColor:Vec4 = vec4(1, 1, 1, 1);
			var endColor:Vec4 = vec4(1, 1, 1, 1);
			var colorif:Float = step(ooutlife, clife1);
			startColor = startColor * colorif + colors[0] * (1 - colorif);
			endColor = endColor * colorif + colors[1] * (1 - colorif);
			startlife = startlife * colorif + clife1 * (1 - colorif);
			endlife = endlife * colorif + clife2 * (1 - colorif);

			colorif = step(ooutlife, clife2);
			startColor = startColor * colorif + colors[1] * (1 - colorif);
			endColor = endColor * colorif + colors[2] * (1 - colorif);
			startlife = startlife * colorif + clife2 * (1 - colorif);
			endlife = endlife * colorif + clife3 * (1 - colorif);

			colorif = step(ooutlife, clife3);
			startColor = startColor * colorif + colors[2] * (1 - colorif);
			endColor = endColor * colorif + colors[3] * (1 - colorif);
			startlife = startlife * colorif + clife3 * (1 - colorif);
			endlife = endlife * colorif + clife4 * (1 - colorif);

			// 最终值3
			var centerColor = startColor + (endColor - startColor) * (ooutlife / endlife);

			// colorif = step(ooutlife, clife4);
			// startColor = startColor * colorif + colors[3] * (1 - colorif);
			// 计算出结束过渡值

			trace("life:", clife1, clife2, clife3, clife4);
			trace("startColor:", ooutlife, startColor);
			trace("endColor:", ooutlife, endColor);
			trace("startLife", startlife);
			trace("endLife", endlife);
			trace("centerColor:", centerColor, (ooutlife / endlife));
			trace("\n");
		}
	}
}
