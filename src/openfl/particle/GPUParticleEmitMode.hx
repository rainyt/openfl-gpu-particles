package openfl.particle;

/**
 * GPU粒子发射模式
 */
 enum GPUParticleEmitMode {
	/**
		A single Point, emit in all directions
	**/
	Point;

	/**
		A cone, parametrized with emitAngle and emitDistance
	**/
	Cone;

	/**
		The GpuParticles specified volumeBounds
	**/
	VolumeBounds;

	/**
		The GpuParticles parent.getBounds()
	**/
	ParentBounds;

	/**
		Same as VolumeBounds, but in Camera space, not world space.
	**/
	CameraBounds;

	/**
		A disc, emit in one direction
	**/
	Disc;
}
