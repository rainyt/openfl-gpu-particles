package openfl.shader;

import openfl.display.ShaderParameter;
#if zygameui
import zygame.core.Start;
#else
import openfl.display.Stage;
#end
import glsl.OpenFLGraphicsShader;
import VectorMath;

/**
 * GPU粒子系统着色器
 */
@:autoBuild(glsl.macro.GLSLCompileMacro.build())
class GPUParticleShader extends OpenFLGraphicsShader {
	/**
	 * 开始颜色值
	 */
	@:attribute public var startColor:Vec4;

	/**
	 * 结束颜色值
	 */
	@:attribute public var endColor:Vec4;

	/**
	 * 颜色的差值
	 */
	// @:attribute public var colorDToffest:Vec2;

	/**
	 * 旋转角度，x=开始角度，y=结束角度，z=颜色过渡开始差值，w=颜色过渡结束差值
	 */
	@:attribute public var rotaAndColorDToffest:Vec4;

	/**
	 * 动态点，如果z为0时，则使用动态点，不使用原坐标
	 */
	@:attribute public var dynamicPos:Vec3;

	/**
	 * 初始化坐标
	 */
	@:attribute public var pos:Vec2;

	/**
	 * 随机值
	 */
	@:attribute public var random:Float;

	/**
	 * 向量方向
	 */
	@:attribute public var velocity:Vec2;

	/**
	 * 加速力
	 */
	@:attribute public var acceleration:Vec2;

	/**
	 * 重力以及切向向量
	 */
	@:attribute public var gravityxAndTangential:Vec4;

	/**
	 * scaleXY属性，开始scale大小，scaleX[start],scaleX[end],scaleY[start],scaleY[end]
	 */
	@:attribute public var scaleXXYY:Vec4;

	/**
	 * 粒子时长，秒，总持续时长
	 */
	@:attribute public var lifeAndDuration:Vec2;

	/**
	 * 当前运行时
	 */
	@:uniform public var time:Float;

	/**
	 * 舞台尺寸以及全局透明度
	 */
	@:uniform public var stageSizeAlpha:Vec3;

	/**
	 * 是否循环
	 */
	@:uniform public var loop:Float;

	/**
	 * 是否循环播放
	 */
	// @:uniform

	/**
	 * 剩余的生命周期
	 */
	@:varying public var outlife:Float;

	/**
	 * 颜色过渡
	 */
	@:varying public var colorv:Vec4;

	/**
	 * 生命可见度
	 */
	@:varying public var lifeAlpha:Float;

	public function new() {
		super();
		u_time.value = [0];
		a_random.value = [];
		a_acceleration.value = [];
		a_velocity.value = [];
		u_loop.value = [1];
	}

	/**
	 * 旋转实现
	 * @return Mat4
	 */
	@:vertexglsl public function rotaion(degrees:Float, axis:Vec3, ts:Vec3):Mat4 {
		var tx:Float = ts.x;
		var ty:Float = ts.y;
		var tz:Float = ts.z;

		var radian:Float = degrees * 3.14 / 180;
		var c:Float = cos(radian);
		var s:Float = sin(radian);
		var x:Float = axis.x;
		var y:Float = axis.y;
		var z:Float = axis.z;
		var x2:Float = x * x;
		var y2:Float = y * y;
		var z2:Float = z * z;
		var ls:Float = x2 + y2 + z2;
		if (ls != 0) {
			var l:Float = sqrt(ls);
			x /= l;
			y /= l;
			z /= l;
			x2 /= ls;
			y2 /= ls;
			z2 /= ls;
		}
		var ccos:Float = 1 - c;
		var d:Mat4 = gl_openfl_Matrix;
		d[0].x = x2 + (y2 + z2) * c;
		d[0].y = x * y * ccos + z * s;
		d[0].z = x * z * ccos - y * s;
		d[1].x = x * y * ccos - z * s;
		d[1].y = y2 + (x2 + z2) * c;
		d[1].z = y * z * ccos + x * s;
		d[2].x = x * z * ccos + y * s;
		d[2].y = y * z * ccos - x * s;
		d[2].z = z2 + (x2 + y2) * c;
		d[3].x = (tx * (y2 + z2) - x * (ty * y + tz * z)) * ccos + (ty * z - tz * y) * s;
		d[3].y = (ty * (x2 + z2) - y * (tx * x + tz * z)) * ccos + (tz * x - tx * z) * s;
		d[3].z = (tz * (x2 + y2) - z * (tx * x + ty * y)) * ccos + (tx * y - ty * x) * s;
		return d;
	}

	/**
	 * 比例缩放
	 * @param scaleX 
	 * @param scaleY 
	 */
	@:vertexglsl public function scale(xScale:Float, yScale:Float):Mat4 {
		return mat4(xScale, 0.0, 0.0, 0.0, 0.0, yScale, 0.0, 0.0, 0.0, 0.0, 1, 0.0, 0.0, 0.0, 0.0, 1.0);
	}

	/**
	 * 平移
	 * @param x 
	 * @param y 
	 */
	@:vertexglsl public function translation(x:Float, y:Float):Mat4 {
		return mat4(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, x, y, 0, 0);
	}

	override function vertex() {
		super.vertex();

		// 生命
		var nowtime:Float = time - lifeAndDuration.x * random;
		var aliveTime:Float = mod(nowtime, lifeAndDuration.x);
		aliveTime = aliveTime * step(0, nowtime);

		// 剩余的生命周期
		this.outlife = (lifeAndDuration.x - aliveTime) / lifeAndDuration.x;
		var ooutlife:Float = 1 - outlife;

		var tweenScale:Float = rotaAndColorDToffest.w - rotaAndColorDToffest.z;
		var coutlife:Float = (ooutlife - rotaAndColorDToffest.z) / tweenScale;
		colorv = startColor + (endColor - startColor) * coutlife;

		// 准备原坐标
		var mat:Mat4 = gl_openfl_Matrix;

		lifeAlpha = 1;

		// 非循环
		if (loop == 0 && nowtime >= lifeAndDuration.y || nowtime < 0) {
			lifeAlpha = 0;
		}

		// 缩放
		var sx:Float = scaleXXYY.x * outlife + scaleXXYY.y * ooutlife;
		var sy:Float = scaleXXYY.z * outlife + scaleXXYY.w * ooutlife;
		var s:Mat4 = scale(sx, sy);

		// 角度：开始角度 + (最终角度 - 开始角度) * 剩余生命
		var endrotaion:Float = (rotaAndColorDToffest.y - rotaAndColorDToffest.x);
		var d:Mat4 = rotaion(rotaAndColorDToffest.x + endrotaion * outlife, vec3(0, 0, 1),
			vec3(sx * gl_openfl_TextureSize.x * 0.5, sy * gl_openfl_TextureSize.y * 0.5, 0));

		// 平移
		var smove:Vec2 = vec2((sx - 1.) * 0.25 * 0.25 * gl_openfl_TextureSize.x, (sy - 1.) * 0.25 * 0.25 * gl_openfl_TextureSize.y);

		// UV位移
		var uv:Vec2 = 2. / stageSizeAlpha.xy;

		// 坐标实现
		var mvec2:Vec2 = acceleration + gravityxAndTangential.xy + gravityxAndTangential.zw;
		var positionNew:Vec2 = pos + velocity * aliveTime + mvec2 * aliveTime * aliveTime;

		// 动态坐标实现
		mat[3].x = mat[3].x * (1. - dynamicPos.z) + (dynamicPos.x * uv.x - 1.) * dynamicPos.z;
		mat[3].y = mat[3].y * (1. - dynamicPos.z) - (dynamicPos.y * uv.y - 1.) * dynamicPos.z;

		// 最终位移
		var t:Mat4 = translation(-uv.x * (gl_openfl_TextureSize.x * 0.5 * sx + smove.x - positionNew.x),
			uv.y * (gl_openfl_TextureSize.y * 0.5 * sy + smove.y - positionNew.y));
		// 位移
		this.gl_Position = (mat + t) * d * s * gl_openfl_Position;
	}

	override function fragment() {
		super.fragment();
		// 尝试改进
		color.rgb += color.rgb * colorv.rgb;
		color.rgba *= colorv.a;
		this.gl_FragColor = color * lifeAlpha * gl_openfl_Alphav * stageSizeAlpha.z;
	}

	override function onFrame() {
		super.onFrame();
	}
}
