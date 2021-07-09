package openfl.particle;

import openfl.particle.GPUParticleEmitMode;

/**
 * 用于解析通用的粒子JSON格式文件，如支持Particle Designer导出的粒子特效
 */
class GPUJSONParticleSprite extends GPUParticleSprite {
	public var data:GPUJSONParticleSpriteJSONData;

	public function new(data:GPUJSONParticleSpriteJSONData) {
		super();
		this.data = data;
		this.loop = true;
		var random = new GPURandomTowAttribute(0., 1);
		// 设置开始颜色
		this.colorAttribute.start.setColor(data.startColorRed, data.startColorGreen, data.startColorBlue, data.startColorAlpha);
		// 设置结束颜色
		this.colorAttribute.end.setColor(data.finishColorRed, data.finishColorGreen, data.finishColorBlue, data.finishColorAlpha);
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
		this.velocity.x = 0;
		this.velocity.y = data.speed;
		this.velocityVariance.x = 0;
		this.velocityVariance.y = data.speedVariance;
		this.gravity.x = data.gravityx;
		this.gravity.y = data.gravityy;
	}

	override function start() {
		// 设置粒子的初始化大小
		var scale1 = data.startParticleSize / texture.width;
		var scale2 = (data.startParticleSize + data.startParticleSizeVariance) / texture.width;
		var random:GPURandomTowAttribute = new GPURandomTowAttribute(scale1, scale2);
		this.scaleXAttribute.start = random;
		this.scaleYAttribute.start = random;
		// 设置粒子的结束大小
		scale1 = data.finishParticleSize / texture.width;
		scale2 = (data.finishParticleSize + data.finishParticleSizeVariance) / texture.width;
		var random:GPURandomTowAttribute = new GPURandomTowAttribute(scale1, scale2);
		this.scaleXAttribute.end = random;
		this.scaleYAttribute.end = random;
		super.start();
	}
}

typedef GPUJSONParticleSpriteJSONData = {
	// ok
	startColorAlpha:Float,
	startParticleSizeVariance:Int,
	// ok
	startColorGreen:Float,
	rotatePerSecond:Float,
	radialAcceleration:Float,
	yCoordFlipped:Float,
	// ok
	emitterType:Float,
	blendFuncSource:Float,
	finishColorVarianceAlpha:Float,
	rotationEnd:Float,
	startColorVarianceBlue:Float,
	rotatePerSecondVariance:Float,
	// ok
	particleLifespan:Float,
	minRadius:Float,
	configName:String,
	tangentialAcceleration:Float,
	rotationStart:Float,
	startColorVarianceGreen:Float,
	speed:Float,
	minRadiusVariance:Float,
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
	finishColorVarianceRed:Float,
	absolutePosition:Bool,
	textureFileName:String,
	startColorVarianceAlpha:Float,
	// ok
	maxParticles:Int,
	finishColorVarianceGreen:Float,
	// ok
	finishParticleSize:Int,
	duration:Float,
	startColorVarianceRed:Float,
	// ok
	finishColorRed:Float,
	// ok
	gravityx:Float,
	maxRadiusVariance:Float,
	// ok
	finishParticleSizeVariance:Int,
	// ok
	gravityy:Float,
	rotationEndVariance:Float,
	// ok
	startColorBlue:Float,
	rotationStartVariance:Float,
	speedVariance:Float,
	radialAccelVariance:Float,
	tangentialAccelVariance:Float,
	// ok
	particleLifespanVariance:Float,
	angleVariance:Float,
	angle:Float,
	maxRadius:Float
}