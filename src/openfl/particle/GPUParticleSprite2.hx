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
	 * 粒子生命
	 */
	public var life:Float = 1;

	/**
	 * 粒子生命方差
	 */
	public var lifeVariance:Float = 0;

	/**
	 * 整个粒子系统生命持续时长，-1为无限循环
	 */
	public var duration:Float = 0;

	/**
	 * 是否循环
	 */
	public var loop(get, never):Bool;

	/**
	 * 发射角度
	 */
	public var emitRotation:GPUAttribute = new GPUOneAttribute(0);

	/**
	 * 发射方向范围
	 */
	public var velocity:GPUTwoAttribute = new GPUTwoAttribute();

	/**
	 * 重力
	 */
	public var gravity:GPUTwoAttribute = new GPUTwoAttribute();

	/**
	 * 加速力
	 */
	public var acceleration:GPUTwoAttribute = new GPUTwoAttribute();

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
	public var colorAttribute:GPUGroupFourAttribute = new GPUGroupFourAttribute(new GPUFourAttribute(), new GPUFourAttribute());

	private var _vertices:Vector<Float>;

	private var _triangles:Vector<Int>;

	private var _uv:Vector<Float>;

	private var _pos:Point = new Point();

	public function new() {
		super();
		_shader = new GPUParticleShader();
		this.blendMode = BlendMode.SCREEN;
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
					var id = value.id * 18;

					_shader.a_dynamicPos.value[id] = _pos.x;
					_shader.a_dynamicPos.value[id + 1] = _pos.y;
					_shader.a_dynamicPos.value[id + 2] = 1;
					_shader.a_dynamicPos.value[id + 3] = _pos.x;
					_shader.a_dynamicPos.value[id + 4] = _pos.y;
					_shader.a_dynamicPos.value[id + 5] = 1;
					_shader.a_dynamicPos.value[id + 6] = _pos.x;
					_shader.a_dynamicPos.value[id + 7] = _pos.y;
					_shader.a_dynamicPos.value[id + 8] = 1;
					_shader.a_dynamicPos.value[id + 9] = _pos.x;
					_shader.a_dynamicPos.value[id + 10] = _pos.y;
					_shader.a_dynamicPos.value[id + 11] = 1;
					_shader.a_dynamicPos.value[id + 12] = _pos.x;
					_shader.a_dynamicPos.value[id + 13] = _pos.y;
					_shader.a_dynamicPos.value[id + 14] = 1;
					_shader.a_dynamicPos.value[id + 15] = _pos.x;
					_shader.a_dynamicPos.value[id + 16] = _pos.y;
					_shader.a_dynamicPos.value[id + 17] = 1;
					var sx = Math.random() * widthRange * 2 - widthRange;
					var sy = Math.random() * heightRange * 2 - heightRange;
					var id = value.id * 12;

					_shader.a_pos.value[id] = sx;
					_shader.a_pos.value[id + 1] = sy;
					_shader.a_pos.value[id + 2] = sx;
					_shader.a_pos.value[id + 3] = sy;
					_shader.a_pos.value[id + 4] = sx;
					_shader.a_pos.value[id + 5] = sy;
					_shader.a_pos.value[id + 6] = sx;
					_shader.a_pos.value[id + 7] = sy;
					_shader.a_pos.value[id + 8] = sx;
					_shader.a_pos.value[id + 9] = sy;
					_shader.a_pos.value[id + 10] = sx;
					_shader.a_pos.value[id + 11] = sy;
				}
			}
		} else {
			for (index => value in childs) {
				if (value.onReset()) {
					var sx = Math.random() * widthRange * 2 - widthRange;
					var sy = Math.random() * heightRange * 2 - heightRange;
					var id = value.id * 12;

					// var posAngle = Math.atan2((-sx), (-sy));
					var posAngle = Math.atan2((sy), (sx));
					var ax = acceleration.x.getValue();
					var ay = acceleration.y.getValue();
					// 加速力
					var ax1:Float = Math.cos(posAngle) * ax + Math.sin(posAngle) * ay;
					var ay1:Float = Math.cos(posAngle) * ay - Math.sin(posAngle) * ax;

					ax = ax1;
					ay = -ay1;
					_shader.a_acceleration.value[id] = ax;
					_shader.a_acceleration.value[id + 1] = ay;
					_shader.a_acceleration.value[id + 2] = ax;
					_shader.a_acceleration.value[id + 3] = ay;
					_shader.a_acceleration.value[id + 4] = ax;
					_shader.a_acceleration.value[id + 5] = ay;
					_shader.a_acceleration.value[id + 6] = ax;
					_shader.a_acceleration.value[id + 7] = ay;
					_shader.a_acceleration.value[id + 8] = ax;
					_shader.a_acceleration.value[id + 9] = ay;
					_shader.a_acceleration.value[id + 10] = ax;
					_shader.a_acceleration.value[id + 11] = ay;
					_shader.a_pos.value[id] = sx;
					_shader.a_pos.value[id + 1] = sy;
					_shader.a_pos.value[id + 2] = sx;
					_shader.a_pos.value[id + 3] = sy;
					_shader.a_pos.value[id + 4] = sx;
					_shader.a_pos.value[id + 5] = sy;
					_shader.a_pos.value[id + 6] = sx;
					_shader.a_pos.value[id + 7] = sy;
					_shader.a_pos.value[id + 8] = sx;
					_shader.a_pos.value[id + 9] = sy;
					_shader.a_pos.value[id + 10] = sx;
					_shader.a_pos.value[id + 11] = sy;
				}
			}
		}
		#if zygameui
		_shader.u_stageSize.value = [Start.current.getStageWidth(), Start.current.getStageHeight()];
		#else
		_shader.u_stageSize.value = [stage.stageWidth, stage.stageHeight];
		#end
		_shader.u_loop.value = [duration == -1 ? 1 : 0];
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
		_shader.data.bitmap.input = texture;
		this.graphics.clear();
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
			
			child.reset();
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
		return duration == -1;
	}
}
