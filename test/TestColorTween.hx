import VectorMath.vec4;
import openfl.particle.data.GPUFourAttribute;
import openfl.particle.data.GPUGroupFourAttribute;

class TestColorTween {
	static function main() {
		var aliveTime = 0.;
		var life = 1;

		var colorAttribute = new GPUGroupFourAttribute(new GPUFourAttribute(), new GPUFourAttribute());
		colorAttribute.tween.pushAttribute(30, new GPUFourAttribute(1, 0, 0, 1));
		colorAttribute.tween.pushAttribute(30, new GPUFourAttribute(0, 1, 0, 1));
		colorAttribute.tween.pushAttribute(30, new GPUFourAttribute(0, 0, 1, 1));
		colorAttribute.tween.pushAttribute(30, new GPUFourAttribute(1, 1, 0, 1));
		colorAttribute.tween.updateWeight();

		while (aliveTime < life) {
			aliveTime += 0.05;
			var tscale = aliveTime / life;
			var data = colorAttribute.getStartAndEndTweenColor(tscale);

			// 最终比例捡取当前比例，得到当前颜色过渡的比例值
			var tweenScale = data.endoffest - data.startoffest;
			// 当前比例值捡取开始比例值，得到当前比例值0
			var tweenStart = aliveTime - data.startoffest;
			// 比率
			var tweenScale2 = tscale / tweenStart;

			// tscale -= data.startoffest;
			// tscale = tscale / tweenScale;

			var start:GPUFourAttribute = data.start;
			var end:GPUFourAttribute = data.end;
			var startColor1 = start.x.getValue();
			var startColor2 = start.y.getValue();
			var startColor3 = start.z.getValue();
			var startColor4 = start.w.getValue();

			var endColor1 = end.x.getValue();
			var endColor2 = end.y.getValue();
			var endColor3 = end.z.getValue();
			var endColor4 = end.w.getValue();

			// if (aliveTime == 0.3) {
				trace("rootstart", startColor1, startColor2, startColor3, startColor4);
				trace("rootend", endColor1, endColor2, endColor3, endColor4);
			// }

			var c1 = (endColor1 - startColor1) / tweenScale * data.startoffest * tweenScale2;
			var c2 = (endColor2 - startColor2) / tweenScale * data.startoffest * tweenScale2;
			var c3 = (endColor3 - startColor3) / tweenScale * data.startoffest * tweenScale2;
			var c4 = (endColor4 - startColor4) / tweenScale * data.startoffest * tweenScale2;
			startColor1 -= c1;
			startColor2 -= c2;
			startColor3 -= c3;
			startColor4 -= c4;

			var c1 = (endColor1 - startColor1) / tweenScale * (1 - data.endoffest) * tweenScale2;
			var c2 = (endColor2 - startColor2) / tweenScale * (1 - data.endoffest) * tweenScale2;
			var c3 = (endColor3 - startColor3) / tweenScale * (1 - data.endoffest) * tweenScale2;
			var c4 = (endColor4 - startColor4) / tweenScale * (1 - data.endoffest) * tweenScale2;
			endColor1 += c1;
			endColor2 += c2;
			endColor3 += c3;
			endColor4 += c4;

			// 剩余的生命周期
			var ooutlife:Float = tscale;
			var startColorv4 = vec4(startColor1, startColor2, startColor3, startColor4);
			var endColorv4 = vec4(endColor1, endColor2, endColor3, endColor4);
			var colorv = startColorv4 + (endColorv4 - startColorv4) * ooutlife;

			// if (aliveTime == 0.3) {
				trace("start", data.startoffest, "end", data.endoffest);
				trace("tweenScale", tweenScale, "1-end", 1 - data.endoffest);
				trace("tweenStart", tweenStart, "比率：", tweenScale2);
				trace(aliveTime, "color:", startColor1, startColor2, startColor3, startColor4);
				trace(aliveTime, "color:", endColor1, endColor2, endColor3, endColor4);
				trace("colorv", colorv);
				trace("\n");
			// }
		}
	}
}
