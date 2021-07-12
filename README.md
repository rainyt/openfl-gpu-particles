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

# 支持
- 1、加载通用粒子文件（JSON格式）；(Load the general particle file (JSON format))
- 2、颜色支持多个颜色过渡；(Color supports multiple color transitions)
- 3、支持通用粒子的重力模式，径向模式暂未支持；(The gravity mode of general particles is supported, but the radial mode is not)
- 4、支持所有参数随机；(All parameters are random)
- 5、由GPU实现的粒子渲染逻辑；(Particle rendering logic implemented by GPU)

# 路线图

### GPU粒子编辑器
仍然在开放中

### GPUParticleSprite.fromJson
现在可以通过fromJson来加载一些通用JSON格式的粒子特效，例如`Particle Designer`等通用工具生成的粒子文件，但部分参数仍然在开发当中。
```haxe
// JSON粒子DEMO
Assets.loadText("assets/fish31_lizi.json").onComplete(function(data) {
  // Create JSON Particle
  var jsonParticle = GPUParticleSprite.fromJson(Json.parse(data), texture);
  this.addChild(jsonParticle);
  jsonParticle.x = stage.stageWidth / 2;
  jsonParticle.y = stage.stageHeight / 2;
  jsonParticle.start();

  // Stop event
  jsonParticle.addEventListener(ParticleEvent.STOP,function(data){
    trace("stop!");
  });
});
```

### 事件流
为粒子系统添加了粒子事件，如播放完成事件：
```haxe
// Stop event
jsonParticle.addEventListener(ParticleEvent.STOP,function(data){
  trace("stop!");
});
```

### 基础使用
创建一个新的粒子对象，可直接参考samples目录
```haxe
// 创建
var gpuSystem = new GPUParticleSprite();
// 添加到舞台
this.addChild(gpuSystem);
// 设置粒子动态更新
gpuSystem.dynamicEmitPoint = false;
// 设置粒子的发生方式
gpuSystem.emitMode = Point;
// 设置粒子的纹理
gpuSystem.texture = texture;
// 设置粒子数量
gpuSystem.counts = 15;
// 设置是否循环
gpuSystem.duration = 0;
// 发射角度
gpuSystem.emitRotation = new GPURandomTwoAttribute(60, 120);
// 设置粒子方向范围
gpuSystem.velocity.x.asOneAttribute().value = 100;
gpuSystem.velocity.y.asOneAttribute().value = 0;
// 设置粒子重力
gpuSystem.gravity.x.asOneAttribute().value = 0;
gpuSystem.gravity.y.asOneAttribute().value = -150;
// 设置粒子加速力
gpuSystem.acceleration.x.asOneAttribute().value = 50;
// 设置粒子切向加速力
gpuSystem.tangential.x = new GPURandomTwoAttribute(-1000,1000);
// 设置粒子的生命力
gpuSystem.life = 0.15;
// 设置粒子的初始点范围
gpuSystem.widthRange = 25;
gpuSystem.heightRange = 25;
// 设置粒子的缩放系数
var startrandom = new GPURandomTwoAttribute(1, 1);
var random = new GPURandomTwoAttribute(0.1, 0.2);
gpuSystem.scaleXAttribute.start = startrandom;
gpuSystem.scaleYAttribute.start = startrandom;
gpuSystem.scaleXAttribute.end = random;
gpuSystem.scaleYAttribute.end = random;
gpuSystem.x = Std.int(getStageWidth() * Math.random());
gpuSystem.y = Std.int(getStageHeight() * Math.random());
// gpuSystem.x =
// 角度
gpuSystem.rotaionAttribute.start = new GPURandomTwoAttribute(0, 360);
gpuSystem.rotaionAttribute.end = new GPURandomTwoAttribute(0, 360);
// 颜色
var random = new GPURandomTwoAttribute(0, 1);
gpuSystem.colorAttribute.start = new GPUFourAttribute(1, 0.5, 0.2, 0);
// 颜色过渡值，由权重计算
gpuSystem.colorAttribute.tween.pushAttribute(10, new GPUFourAttribute(1, 0.2, 0, 0.5));
gpuSystem.colorAttribute.tween.pushAttribute(5, new GPUFourAttribute(1, 1., 0., 1));
// gpuSystem.colorAttribute.tween.pushAttribute(5, new GPUFourAttribute(1, 1, 0, 1));
gpuSystem.colorAttribute.tween.pushAttribute(25, new GPUFourAttribute(1, 0, 0, 0.5));
gpuSystem.colorAttribute.tween.pushAttribute(25, new GPUFourAttribute(1, 0, 0, 0));
// gpuSystem.colorAttribute.end = new GPUFourAttribute(random, random, random, 1);
// 开始发射
gpuSystem.start();
```
