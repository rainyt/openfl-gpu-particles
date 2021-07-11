package openfl.particle;

import openfl.particle.data.*;
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
import openfl.particle.events.ParticleEvent;

/**
 * GPU粒子系统
 */
class GPUParticleSprite extends Sprite #if zygame implements Refresher #end {
	/**
	 * 通过JSON解析GPU粒子
	 * @param json 
	 */
	public static function fromJson(json:Dynamic, texture:BitmapData = null):GPUJSONParticleSprite {
		return new GPUJSONParticleSprite(json, texture);
	}

	/**
	 * 是否正在播放
	 */
	public var isPlay(get, never):Bool;

	private var _isPlay:Bool = false;

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
	 * 切向加速力
	 */
	public var tangential:GPUTwoAttribute = new GPUTwoAttribute();

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

	/**
	 * 粒子存活数量
	 */
	public var particleLiveCounts:Int;

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
		_isPlay = true;
		#if zygame
		Start.current.addToUpdate(this);
		#else
		this.addEventListener(Event.ENTER_FRAME, onFrame);
		#end
	}

	public function stop() {
		_isPlay = false;
		#if zygame
		Start.current.removeToUpdate(this);
		#else
		this.removeEventListener(Event.ENTER_FRAME, onFrame);
		#end
	}

	public function onFrame(#if !zygameui e:Event #end) {
		this.time += 1 / 60;
		particleLiveCounts = 0;
		for (index => value in childs) {
			if (!value.isDie()) {
				particleLiveCounts++;
			}
			if (value.onReset()) {
				value.reset();
			} else {
				if (colorAttribute.hasTween()) {
					// 存在过渡
					value.updateTweenColor();
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
		if (this.duration != -1 && particleLiveCounts == 0) {
			this.time = 0;
			this.stop();
			this.dispatchEvent(new ParticleEvent(ParticleEvent.STOP));
		}
	}

	/**
	 * 初始化所有粒子
	 */
	private function _init() {
		if (texture == null)
			return;
		this.colorAttribute.tween.updateWeight();
		this.scaleXAttribute.tween.updateWeight();
		this.scaleYAttribute.tween.updateWeight();
		this.rotaionAttribute.tween.updateWeight();
		_shader.data.bitmap.input = texture;
		this.graphics.clear();
		this.graphics.beginShaderFill(_shader);
		var vertices:Vector<Float> = new Vector();
		var triangles:Vector<Int> = new Vector();
		var uv:Vector<Float> = new Vector();
		_shader.a_random.value = [];
		_shader.a_acceleration.value = [];
		_shader.a_velocity.value = [];
		_shader.a_pos.value = [];
		_shader.a_scaleXXYY.value = [];
		_shader.a_dynamicPos.value = [];
		_shader.a_rotaAndColorDToffest.value = [];
		_shader.a_startColor.value = [];
		_shader.a_endColor.value = [];
		_shader.a_gravityxAndTangential.value = [];
		_shader.a_lifeAndDuration.value = [];
		// _shader.a_colorDToffest.value = [];
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

	function get_isPlay():Bool {
		return _isPlay;
	}

	public function dispose():Void {
		for (index => value in this.childs) {
			value.dispose();
		}
		this.childs = null;
	}
}
