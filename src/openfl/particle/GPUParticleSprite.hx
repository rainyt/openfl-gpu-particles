package openfl.particle;

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
	public var velocity:GPUVec2;

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

	private var _vertices:Vector<Float>;

	private var _triangles:Vector<Int>;

	private var _uv:Vector<Float>;

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
			for (index => value in childs) {
				if (value.onReset()) {
					_shader.a_dynamicPos.value[value.id * 18] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 1] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 2] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 3] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 4] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 5] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 6] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 7] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 8] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 9] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 10] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 11] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 12] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 13] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 14] = 1;
					_shader.a_dynamicPos.value[value.id * 18 + 15] = this.x;
					_shader.a_dynamicPos.value[value.id * 18 + 16] = this.y;
					_shader.a_dynamicPos.value[value.id * 18 + 17] = 1;
					// trace("reset", value.id, _shader.a_dynamicPos.value);
					// _shader.a_dynamicPos.value[value.id + 2] = this.x;
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
					vx = Math.random() * velocity.x - velocity.x * 0.5;
					vy = Math.random() * velocity.y - velocity.y * 0.5;
					ax = Math.random() * gravity.x;
					ay = Math.random() * gravity.y;
				default:
					angle = emitRotation * Math.PI / 180;
					// var vx = Math.random() * velocity.x - velocity.x * 0.5;
					// var vy = Math.random() * velocity.y - velocity.y * 0.5;
					vx = Math.random() * velocity.x;
					vy = Math.random() * velocity.y;
					// vx *= 3;
					// vy *= 3;

					// var ax = Math.random() * gravity.x - gravity.x * 0.5;
					// var ay = Math.random() * gravity.y - gravity.y * 0.5;
					ax = Math.random() * gravity.x;
					ay = Math.random() * gravity.y;
					// ax *= 3;
					// ay *= 3;
			}

			var vx1:Float = Math.cos(angle) * vx + Math.sin(angle) * vy;
			var vy1:Float = Math.cos(angle) * vy - Math.sin(angle) * vx;
			vx = vx1;
			vy = vy1;

			var scaleXstart:Float = scaleXAttribute.start.getValue();
			var scaleYstart:Float = scaleYAttribute.start == scaleXAttribute.start ? scaleXstart : scaleYAttribute.start.getValue();
			var scaleXend:Float = scaleXAttribute.end.getValue();
			var scaleYend:Float = scaleYAttribute.end == scaleXAttribute.end ? scaleXend : scaleYAttribute.end.getValue();

			var rlife = Math.random() * life * 0.5 + life * 0.5;

			child.life = rlife;
			child.random = r;

			for (i in 0...6) {
				_shader.a_random.value.push(r);
				_shader.a_velocity.value.push(vx);
				_shader.a_velocity.value.push(vy);
				_shader.a_acceleration.value.push(ax);
				_shader.a_acceleration.value.push(ay);
				_shader.a_life.value.push(rlife);
				_shader.a_pos.value.push(sx);
				_shader.a_pos.value.push(sy);
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
