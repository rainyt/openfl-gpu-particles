package openfl.shader.utils;

import openfl.display.GraphicsShader;
import openfl.display._internal.ShaderBuffer;
import openfl.utils._internal.Float32Array;

@:access(openfl.display.Shader)
class ShaderBufferUtils {
	/**
	 * 更新着色器Buffer工具
	 * @param buffer 
	 * @param shader 
	 * @param updateAllParam 
	 */
	public static function update(buffer:ShaderBuffer, shader:GPUParticleShader, updateParams:UpdateParams):Void {
		#if lime
		buffer.inputCount = 0;
		// overrideCount = 0;
		buffer.overrideIntCount = 0;
		buffer.overrideFloatCount = 0;
		buffer.overrideBoolCount = 0;
		buffer.paramBoolCount = 0;
		buffer.paramCount = 0;
		buffer.paramDataLength = 0;
		buffer.paramFloatCount = 0;
		buffer.paramIntCount = 0;
		buffer.shader = null;

		if (shader == null)
			return;

		shader.__init();

		buffer.inputCount = shader.__inputBitmapData.length;
		var input;

		for (i in 0...buffer.inputCount) {
			input = shader.__inputBitmapData[i];
			buffer.inputs[i] = input.input;
			buffer.inputFilter[i] = input.filter;
			buffer.inputMipFilter[i] = input.mipFilter;
			buffer.inputRefs[i] = input;
			buffer.inputWrap[i] = input.wrap;
		}

		var boolCount = shader.__paramBool.length;
		var floatCount = shader.__paramFloat.length;
		var intCount = shader.__paramInt.length;
		buffer.paramCount = boolCount + floatCount + intCount;
		buffer.paramBoolCount = boolCount;
		buffer.paramFloatCount = floatCount;
		buffer.paramIntCount = intCount;

		var length = 0, p = 0;
		var param;

		for (i in 0...boolCount) {
			param = shader.__paramBool[i];

			buffer.paramPositions[p] = buffer.paramDataLength;
			length = (param.value != null ? param.value.length : 0);
			buffer.paramLengths[p] = length;
			buffer.paramDataLength += length;
			buffer.paramTypes[p] = 0;

			buffer.paramRefs_Bool[i] = param;
			p++;
		}

		var param;

		for (i in 0...floatCount) {
			param = shader.__paramFloat[i];

			buffer.paramPositions[p] = buffer.paramDataLength;
			length = (param.value != null ? param.value.length : 0);
			buffer.paramLengths[p] = length;
			buffer.paramDataLength += length;
			buffer.paramTypes[p] = 1;

			buffer.paramRefs_Float[i] = param;
			p++;
		}

		var param;

		for (i in 0...intCount) {
			param = shader.__paramInt[i];

			buffer.paramPositions[p] = buffer.paramDataLength;
			length = (param.value != null ? param.value.length : 0);
			buffer.paramLengths[p] = length;
			buffer.paramDataLength += length;
			buffer.paramTypes[p] = 2;

			buffer.paramRefs_Int[i] = param;
			p++;
		}

		if (buffer.paramDataLength > 0) {
			if (buffer.paramData == null) {
				updateParams = null;
				buffer.paramData = new Float32Array(buffer.paramDataLength);
			} else if (buffer.paramDataLength > buffer.paramData.length) {
				updateParams = null;
				var data = new Float32Array(buffer.paramDataLength);
				data.set(buffer.paramData);
				buffer.paramData = data;
			}
		}

		var boolIndex = 0;
		var floatIndex = 0;
		var intIndex = 0;

		var paramPosition:Int = 0;
		var boolParam = null, floatParam = null, intParam = null, length = 0;

		for (i in 0...buffer.paramCount) {
			length = buffer.paramLengths[i];

			if (i < boolCount) {
				boolParam = buffer.paramRefs_Bool[boolIndex];
				boolIndex++;

				if (updateParams == null || length <= 4) {
					for (j in 0...length) {
						buffer.paramData[paramPosition] = boolParam.value[j] ? 1 : 0;
						paramPosition++;
					}
				} else {
					paramPosition += length;
				}
			} else if (i < boolCount + floatCount) {
				floatParam = buffer.paramRefs_Float[floatIndex];
				floatIndex++;
				if (updateParams == null || length <= 4) {
					for (j in 0...length) {
						buffer.paramData[paramPosition] = floatParam.value[j];
						paramPosition++;
					}
				} else {
					// 判断粒子对象，是否更新，需要更新的才从这里进行刷新
					// Todo : 是否可以判断当前属性是否需要刷新，而不是全部刷新
					for (index => value in updateParams.childs) {
						if(value == null)
							continue;
						var indexAt = value.id;
						var indexLen = 0;
						if (floatParam.type == FLOAT) {
							indexAt *= 6;
							indexLen = 1;
						} else if (floatParam.type == FLOAT2) {
							indexAt *= 12;
							indexLen = 2;
						} else if (floatParam.type == FLOAT3) {
							indexAt *= 18;
							indexLen = 3;
						} else if (floatParam.type == FLOAT4) {
							indexAt *= 24;
							indexLen = 4;
						}
						var indexJAt = 0;
						for (j in 0...6) {
							for (j2 in 0...indexLen) {
								buffer.paramData[paramPosition + indexAt + j2] = floatParam.value[indexAt + j2];
							}
							indexJAt += indexLen;
							indexAt += indexLen;
						}
					}
					paramPosition += length;
				}
			} else {
				intParam = buffer.paramRefs_Int[intIndex];
				intIndex++;

				if (updateParams == null || length <= 4) {
					for (j in 0...length) {
						buffer.paramData[paramPosition] = intParam.value[j];
						paramPosition++;
					}
				} else {
					paramPosition += length;
				}
			}
		}

		buffer.shader = shader;
		#end
	}
}
