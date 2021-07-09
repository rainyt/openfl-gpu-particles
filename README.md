# openfl-gpu-particles
- 可用于OpenFL渲染的GPU粒子 GPU particles for openfl rendering
- OpenFL：https://github.com/openfl/openfl
- 该库未完成，请等待，当完善时将会发布haxelib。The library has not been completed, please wait. When it is completed, haxelib will be released.

# 依赖库（Dependent library）
- openfl-glsl：https://github.com/rainyt/openfl-glsl
    - 使用该库支持着色器的编写支持。Use this library to support the writing support of shaders.

# 渲染器（Renderer）
- GPUParticleSprite

  使用Sprite绘制三角形、由GPU着色器进行渲染移动、缩放、旋转以及颜色修改等处理，可极大减少CPU的消耗，从而提高性能。Using sprite to draw triangles and GPU shaders to render, move, scale, rotate and modify colors can greatly reduce CPU consumption and improve performance.

# 路线图
### GPUParticleSprite.fromJson
现在可以通过fromJson来加载一些通用JSON格式的粒子特效，例如`Particle Designer`等通用工具生成的粒子文件，但部分参数仍然在开发当中。