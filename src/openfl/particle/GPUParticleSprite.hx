package openfl.particle;

import openfl.geom.Point;
import openfl.events.Event;
#if zygame
import zygame.core.Start;
import zygame.core.Refresher;
#end
import openfl.display.DisplayObject;
import openfl.display.BlendMode;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.shader.GPUParticleShader;
import openfl.display.Sprite;
import VectorMath;

/**
 * GPU粒子系统
 */
class GPUParticleSprite extends Sprite #if zygame implements Refresher #end {
	/**
	 * 通过JSON解析GPU粒子
	 * @param json 
	 */
	public static function fromJson(json:Dynamic):GPUJSONParticleSprite {
		return new GPUJSONParticleSprite(json);
	}

	/**
	 * 子粒子
	 */
	public var childs:Array<GPUParticleChild>;

	/**
	 * 是否设置发射点为动态，默认为false，当为true时，将会随着x,y的坐标发生变化而改编发射点
	 */
	public var dynamicEmitPoint:Bool = false;

	/**
	 * GPU粒子着色器
	 */
	private var _shader:GPUParticleShader;

	/**
	 * 纹理
	 */
	public var texture:BitmapData;

	/**
	 * 发射模式
	 */
	public var emitMode:GPUParticleEmitMode = Point;

	/**
	 * 粒子数量
	 */
	public var counts:Int = 10;

	/**
	 * 当前时间，可设置当前时间来更新粒子
	 */
	public var time(get, set):Float;

	/**
	 * 宽度范围
	 */
	public var widthRange:Float = 0;

	/**
	 * 
	 */
	public var heightRange:Float = 0;

	/**
	 * 持续时长
	 */
	public var life:Float = 1;

	/**
	 * 持续时长的方差
	 */
	public var lifeVariance:Float = 0;

	/**
	 * 是否循环
	 */
	public var loop(get, set):Bool;

	/**
	 * 发射角度
	 */
	public var emitRotation:Float = 45;

	/**
	 * 发射方向范围
	 */
	public var velocity:GPUVec2 = new GPUVec2();

	/**
	 * 发射方向范围方差
	 */
	public var velocityVariance:GPUVec2 = new GPUVec2();

	/**
	 * 重力
	 */
	public var gravity:GPUVec2;

	/**
	 * 缩放属性ScaleX
	 */
	public var scaleXAttribute:GPUGroupAttribute = new GPUGroupAttribute(new GPUOneAttribute(1), new GPUOneAttribute(1));

	/**
	 * 缩放属性ScaleY
	 */
	public var scaleYAttribute:GPUGroupAttribute = new GPUGroupAttribute(new GPUOneAttribute(1), new GPUOneAttribute(1));

	/**
	 * 旋转属性
	 */
	public var rotaionAttribute:GPUGroupAttribute = new GPUGroupAttribute(new GPUOneAttribute(0), new GPUOneAttribute(0));

	/**
	 * 颜色过渡参数
	 */
	// public var colorTweenAttribute:GPUColorTweenAttribute = new GPUColorTweenAttribute();
	public var colorAttribute:GPUGroupFourAttribute = new GPUGroupFourAttribute(new GPUFourAttribute(), new GPUFourAttribute());

	private var _vertices:Vector<Float>;

	private var _triangles:Vector<Int>;

	private var _uv:Vector<Float>;

	private var _pos:Point = new Point();

	public function new() {
		super();
		_shader = new GPUParticleShader();
		this.blendMode = BlendMode.SCREEN;
		velocity = new GPUVec2();
		gravity = new GPUVec2();
	}

	/**
	 * 重置粒子
	 */
	public function reset() {}

	/**
	 * 开始发射粒子
	 */
	public function start() {
		this._init();
		#if zygame
		Start.current.addToUpdate(this);
		#else
		this.addEventListener(Event.ENTER_FRAME, onFrame);
		#end
	}

	public function stop() {
		#if zygame
		Start.current.removeToUpdate(this);
		#else
		this.removeEventListener(Event.ENTER_FRAME, onFrame);
		#end
	}

	#if zygame
	public function onFrame() {
	#else
	public function onFrame(e:Event) {
	#end

		this.time += 1 / 60;
		if (dynamicEmitPoint) {
			_pos.x = this.x;
			_pos.y = this.y;
			_pos = this.parent.localToGlobal(_pos);
			#if zygame
			_pos = Start.current.globalToLocal(_pos);
			#else
			_pos = stage.globalToLocal(_pos);
			#end
			for (index => value in childs) {
				if (value.onReset()) {
					_shader.a_dynamicPos.value[value.id * 18] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 1] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 2] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 3] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 4] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 5] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 6] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 7] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 8] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 9] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 10] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 11] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 12] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 13] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 14] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 15] = _pos.x;
					_shader.a_dynamicPos.value[value.id * 18 + 16] = _pos.y;
					_shader.a_dynamicPos.value[value.id * 18 + 17] = 1;
				}
			}
		}
		#if zygameui
		_shader.u_stageSize.value = [Start.current.getStageWidth(), Start.current.getStageHeight()];
		#else
		_shader.u_stageSize.value = [stage.stageWidth, stage.stageHeight];
		#end
		@:privateAccess for (index => value in this.graphics.__usedShaderBuffers) {
			value.update(value.shader);
		}
		this.invalidate();
	}

	/**
 * 初始化所有粒子
 */
	private function _init() {
		if (texture == null)
			return;
		// this.shader = _shader;
		_shader.data.bitmap.input = texture;
		this.graphics.clear();
		// this.graphics.beginBitmapFill(texture);
		this.graphics.beginShaderFill(_shader);
		var vertices:Vector<Float> = new Vector();
		var triangles:Vector<Int> = new Vector();
		var uv:Vector<Float> = new Vector();
		_shader.a_random.value = [];
		_shader.a_acceleration.value = [];
		_shader.a_velocity.value = [];
		_shader.a_life.value = [];
		_shader.a_pos.value = [];
		_shader.a_scaleXXYY.value = [];
		_shader.a_dynamicPos.value = [];
		_shader.a_rota.value = [];
		_shader.a_startColor.value = [];
		_shader.a_endColor.value = [];
		childs = [];
		for (i in 0...counts) {
			var child = new GPUParticleChild(this, i);
			childs.push(child);

			vertices.push(0);
			vertices.push(0);
			vertices.push(texture.width);
			vertices.push(0);
			vertices.push(texture.width);
			vertices.push(texture.height);
			vertices.push(0);
			vertices.push(texture.height);
			triangles.push(0 + 4 * i);
			triangles.push(1 + 4 * i);
			triangles.push(2 + 4 * i);
			triangles.push(2 + 4 * i);
			triangles.push(3 + 4 * i);
			triangles.push(0 + 4 * i);
			uv.push(0);
			uv.push(0);
			uv.push(1);
			uv.push(0);
			uv.push(1);
			uv.push(1);
			uv.push(0);
			uv.push(1);
			var r = Math.random();

			var vx = 0.;
			var vy = 0.;
			var ax = 0.;
			var ay = 0.;
			var angle = 0.;
			var sx = Math.random() * widthRange - widthRange * 0.5;
			var sy = Math.random() * heightRange - heightRange * 0.5;
			switch (emitMode) {
				case Point:
					angle = Math.random() * 360;
					vx = velocity.x + velocityVariance.x * Math.random();
					vy = velocity.y + velocityVariance.y * Math.random();
					ax = gravity.x;
					ay = gravity.y;
				default:
					angle = emitRotation * Math.PI / 180;
					vx = Math.random() * velocity.x;
					vy = Math.random() * velocity.y;
					ax = Math.random() * gravity.x;
					ay = Math.random() * gravity.y;
			}

			var vx1:Float = Math.cos(angle) * vx + Math.sin(angle) * vy;
			var vy1:Float = Math.cos(angle) * vy - Math.sin(angle) * vx;
			vx = vx1;
			vy = vy1;

			var scaleXstart:Float = scaleXAttribute.start.getValue();
			var scaleYstart:Float = scaleYAttribute.start == scaleXAttribute.start ? scaleXstart : scaleYAttribute.start.getValue();
			var scaleXend:Float = scaleXAttribute.end.getValue();
			var scaleYend:Float = scaleYAttribute.end == scaleXAttribute.end ? scaleXend : scaleYAttribute.end.getValue();

			var startRotaion:Float = rotaionAttribute.start.getValue();
			var endRotaion:Float = rotaionAttribute.end.getValue();

			// 生命+生命方差实现
			var rlife = life + Math.random() * lifeVariance;

			child.life = rlife;
			child.random = r;

			// 颜色过渡配置
			// var ct1:Float = colorTweenAttribute.lifeScale.x.getValue();
			// var ct2:Float = colorTweenAttribute.lifeScale.y.getValue();
			// var ct3:Float = colorTweenAttribute.lifeScale.z.getValue();
			// var ct4:Float = colorTweenAttribute.lifeScale.w.getValue();
			// var colors:Array<Float> = [];
			// for (index => value in colorTweenAttribute.colors) {
			// 	colors.push(value.x.getValue());
			// 	colors.push(value.y.getValue());
			// 	colors.push(value.z.getValue());
			// 	colors.push(value.w.getValue());
			// }
			// if (colors.length == 0) {
			// 	// 即无，所有都是1
			// 	for (i in 0...16) {
			// 		colors.push(1);
			// 	}
			// } else if (colors.length < 16) {
			// 	// 剩余的保持最后4个
			// 	var end1 = colors[colors.length - 4];
			// 	var end2 = colors[colors.length - 3];
			// 	var end3 = colors[colors.length - 2];
			// 	var end4 = colors[colors.length - 1];
			// 	while (colors.length < 16) {
			// 		colors.push(end1);
			// 		colors.push(end2);
			// 		colors.push(end3);
			// 		colors.push(end4);
			// 	}
			// }

			var startColor1 = colorAttribute.start.x.getValue();
			var startColor2 = colorAttribute.start.y.getValue();
			var startColor3 = colorAttribute.start.z.getValue();
			var startColor4 = colorAttribute.start.w.getValue();

			var endColor1 = colorAttribute.end.x.getValue();
			var endColor2 = colorAttribute.end.y.getValue();
			var endColor3 = colorAttribute.end.z.getValue();
			var endColor4 = colorAttribute.end.w.getValue();

			for (i in 0...6) {
				// // 颜色过渡比重
				// _shader.a_colorlife.value.push(ct1);
				// _shader.a_colorlife.value.push(ct2);
				// _shader.a_colorlife.value.push(ct3);
				// _shader.a_colorlife.value.push(ct4);
				// // 颜色过渡值
				// for (index => value in colors) {
				// 	_shader.a_colors.value.push(value);
				// }
				// 颜色过渡
				_shader.a_startColor.value.push(startColor1);
				_shader.a_startColor.value.push(startColor2);
				_shader.a_startColor.value.push(startColor3);
				_shader.a_startColor.value.push(startColor4);
				_shader.a_endColor.value.push(endColor1);
				_shader.a_endColor.value.push(endColor2);
				_shader.a_endColor.value.push(endColor3);
				_shader.a_endColor.value.push(endColor4);
				// 角度
				_shader.a_rota.value.push(startRotaion);
				_shader.a_rota.value.push(endRotaion);
				// 随机值
				_shader.a_random.value.push(r);
				// 移动向量
				_shader.a_velocity.value.push(vx);
				_shader.a_velocity.value.push(vy);
				// 重力
				_shader.a_acceleration.value.push(ax);
				_shader.a_acceleration.value.push(ay);
				// 粒子生存时间
				_shader.a_life.value.push(rlife);
				// 初始化位置
				_shader.a_pos.value.push(sx);
				_shader.a_pos.value.push(sy);
				// 缩放比例
				_shader.a_scaleXXYY.value.push(scaleXstart);
				_shader.a_scaleXXYY.value.push(scaleXend);
				_shader.a_scaleXXYY.value.push(scaleYstart);
				_shader.a_scaleXXYY.value.push(scaleYend);
				// 动态点
				if (dynamicEmitPoint) {
					_shader.a_dynamicPos.value.push(this.x);
					_shader.a_dynamicPos.value.push(this.y);
					_shader.a_dynamicPos.value.push(1);
				} else {
					_shader.a_dynamicPos.value.push(0);
					_shader.a_dynamicPos.value.push(0);
					_shader.a_dynamicPos.value.push(0);
				}
			}
		}
		_vertices = vertices;
		_triangles = triangles;
		_uv = uv;
		// trace("坐标", vertices, "\n顶点", triangles, "\nUV", uv);
		// trace("-着色器", _shader.a_velocity.value);
		// trace("-坐标", vertices.length, "\n顶点", triangles.length, "\nUV", uv.length);
		this.graphics.drawTriangles(vertices, triangles, uv);
		this.graphics.endFill();
	}

	function get_time():Float {
		return this._shader.u_time.value[0];
	}

	function set_time(value:Float):Float {
		this._shader.u_time.value[0] = value;
		return value;
	}

	#if !flash
	/**
 * 重构触摸事件，无法触发触摸的问题
 * @param x
 * @param y
 * @param shapeFlag
 * @param stack
 * @param interactiveOnly
 * @param hitObject
 * @return Bool
 */
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {
		return false;
	}
	#end

	function get_loop():Bool {
		return _shader.u_loop.value[0] == 1;
	}

	function set_loop(value:Bool):Bool {
		_shader.u_loop.value[0] = value ? 1 : 0;
		return value;
	}
}
