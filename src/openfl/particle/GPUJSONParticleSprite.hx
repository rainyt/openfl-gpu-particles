package openfl.particle;

import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.particle.data.*;
import lime.graphics.opengl.GL;

using openfl.particle.Tools;

/**
 * 用于解析通用的粒子JSON格式文件，如支持Particle Designer导出的粒子特效
 */
class GPUJSONParticleSprite extends GPUParticleSprite {
	public var data:GPUJSONParticleSpriteJSONData;

	public function new(data:GPUJSONParticleSpriteJSONData, texture:BitmapData = null) {
		super();
		if (data.blendFuncSource == GL.DST_COLOR) {
			trace("MULTIPLY");
			this.blendMode = BlendMode.MULTIPLY;
		} else if ((data.blendFuncSource == GL.ZERO || data.blendFuncSource == GL.SRC_ALPHA_SATURATE)
			&& data.blendFuncDestination == GL.ONE_MINUS_SRC_ALPHA) {
			trace("SUBTRACT");
			this.blendMode = BlendMode.SUBTRACT;
		} else if (data.blendFuncSource == GL.ONE && data.blendFuncDestination == GL.ONE) {
			trace("add");
			this.blendMode = BlendMode.ADD;
		} else {
			trace("normal");
			this.blendMode = BlendMode.NORMAL;
		}
		this.data = data;
		this.texture = texture;
		// 系统持续时长
		this.duration = data.duration;
		var random = new GPURandomTwoAttribute(0., 1);
		// 设置开始颜色
		this.colorAttribute.start.x = new GPURandomTwoAttribute(data.startColorRed, data.startColorRed + data.startColorVarianceRed);
		this.colorAttribute.start.y = new GPURandomTwoAttribute(data.startColorGreen, data.startColorGreen + data.startColorVarianceGreen);
		this.colorAttribute.start.z = new GPURandomTwoAttribute(data.startColorBlue, data.startColorBlue + data.startColorVarianceBlue);
		this.colorAttribute.start.w = new GPURandomTwoAttribute(data.startColorAlpha, data.startColorAlpha + data.startColorVarianceAlpha);
		// 设置结束颜色
		this.colorAttribute.end.x = new GPURandomTwoAttribute(data.finishColorRed, data.finishColorRed + data.finishColorVarianceRed);
		this.colorAttribute.end.y = new GPURandomTwoAttribute(data.finishColorGreen, data.finishColorGreen + data.finishColorVarianceGreen);
		this.colorAttribute.end.z = new GPURandomTwoAttribute(data.finishColorBlue, data.finishColorBlue + data.finishColorVarianceGreen);
		this.colorAttribute.end.w = new GPURandomTwoAttribute(data.finishColorAlpha, data.finishColorAlpha + data.finishColorVarianceAlpha);
		// 设置粒子数量
		this.counts = data.maxParticles;
		// 设置粒子生命
		this.life = data.particleLifespan;
		this.lifeVariance = data.particleLifespanVariance;
		// 设置粒子发射类型
		switch (data.emitterType) {
			case 0:
				// 以点发射
				this.emitMode = GPUParticleEmitMode.Point;
		}
		// 设置粒子位置方差
		this.widthRange = data.sourcePositionVariancex;
		this.heightRange = data.sourcePositionVariancey;
		// 设置粒子向量
		this.velocity.y.asOneAttribute().value = 0;
		this.velocity.x = new GPURandomTwoAttribute(data.speed, data.speed + data.speedVariance);
		this.acceleration.x = new GPURandomTwoAttribute(data.radialAcceleration, data.radialAcceleration + data.radialAccelVariance);
		this.acceleration.y.asOneAttribute().value = 0;
		this.tangential.x = new GPURandomTwoAttribute(data.tangentialAcceleration, data.tangentialAcceleration + data.tangentialAccelVariance);
		this.tangential.y.asOneAttribute().value = 0;
		this.gravity.x.asOneAttribute().value = data.gravityx * 0.5;
		this.gravity.y.asOneAttribute().value = -data.gravityy * 0.5;
		// 设置粒子的开始角度
		this.rotaionAttribute.start = new GPURandomTwoAttribute(data.rotationStart, data.rotationStart + data.rotationStartVariance);
		this.rotaionAttribute.end = new GPURandomTwoAttribute(data.rotationEnd, data.rotationEnd + data.rotationEndVariance);
		// 设置粒子发射方向
		this.emitRotation = new GPURandomTwoAttribute(data.angle - data.angleVariance, data.angle + data.angleVariance);
	}

	override function start() {
		var scale1 = Math.min((data.startParticleSize) / texture.width, (data.startParticleSize) / texture.height);
		var scale2 = Math.min((data.startParticleSize + data.startParticleSizeVariance) / texture.width,
			(data.startParticleSize + data.startParticleSizeVariance) / texture.height);
		var startrandom:GPURandomTwoAttribute = new GPURandomTwoAttribute(scale1, scale2);

		// 设置粒子的结束大小
		scale1 = (data.finishParticleSize) / texture.width;
		scale2 = (data.finishParticleSize + data.finishParticleSizeVariance) / texture.width;
		var endrandom:GPURandomTwoAttribute = new GPURandomTwoAttribute(scale1, scale2);

		if (texture.width == texture.height) {
			this.scaleXAttribute.start = startrandom;
			this.scaleYAttribute.start = startrandom;
			this.scaleXAttribute.end = endrandom;
			this.scaleYAttribute.end = endrandom;
		} else if (texture.width > texture.height) {
			this.scaleXAttribute.start = startrandom;
			this.scaleYAttribute.start = new GPUOneAttribute(1);
			this.scaleXAttribute.end = endrandom;
			this.scaleYAttribute.end = new GPUOneAttribute(1);
		} else {
			this.scaleXAttribute.start = new GPUOneAttribute(1);
			this.scaleYAttribute.start = startrandom;
			this.scaleXAttribute.end = new GPUOneAttribute(1);
			this.scaleYAttribute.end = endrandom;
		}

		super.start();
	}
}

/**
 * 通用粒子数据格式
 */
typedef GPUJSONParticleSpriteJSONData = {
	// ok
	startColorAlpha:Float,
	// ok
	startParticleSizeVariance:Int,
	// ok
	startColorGreen:Float,
	// ?
	rotatePerSecond:Float,
	// ok
	radialAcceleration:Float,
	// ?
	yCoordFlipped:Float,
	// ok
	emitterType:Float,
	// ?
	blendFuncSource:Float,
	// ok
	finishColorVarianceAlpha:Float,
	// ok
	rotationEnd:Float,
	// ok
	startColorVarianceBlue:Float,
	rotatePerSecondVariance:Float,
	// ok
	particleLifespan:Float,
	minRadius:Float,
	configName:String,
	// ok
	tangentialAcceleration:Float,
	// ok
	rotationStart:Float,
	// ok
	startColorVarianceGreen:Float,
	// ok
	speed:Float,
	minRadiusVariance:Float,
	// ok
	finishColorVarianceBlue:Float,
	// ok
	finishColorBlue:Float,
	// ok
	finishColorGreen:Float,
	blendFuncDestination:Float,
	// ok
	finishColorAlpha:Float,
	// ok
	sourcePositionVariancex:Float,
	// ok
	startParticleSize:Int,
	// ok
	sourcePositionVariancey:Float,
	// ok
	startColorRed:Float,
	// ok
	finishColorVarianceRed:Float,
	// ?
	absolutePosition:Bool,
	textureFileName:String,
	// ok
	startColorVarianceAlpha:Float,
	// ok
	maxParticles:Int,
	// ok
	finishColorVarianceGreen:Float,
	// ok
	finishParticleSize:Int,
	duration:Float,
	// ok
	startColorVarianceRed:Float,
	// ok
	finishColorRed:Float,
	// todo
	gravityx:Float,
	maxRadiusVariance:Float,
	// ok
	finishParticleSizeVariance:Int,
	// todo
	gravityy:Float,
	// ok
	rotationEndVariance:Float,
	// ok
	startColorBlue:Float,
	// ok
	rotationStartVariance:Float,
	// ok
	speedVariance:Float,
	// ok
	radialAccelVariance:Float,
	// ok
	tangentialAccelVariance:Float,
	// ok
	particleLifespanVariance:Float,
	// ok
	angleVariance:Float,
	// ok
	angle:Float,
	maxRadius:Float
}
