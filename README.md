这是一个使用GPUImage录制实时滤镜录像的例子，会涉及到
- git submodule 的使用
- 在项目中引用别的项目
- GPUImage的逻辑

一、创建工程，到工程的根目录,执行以下操作
```
git init
git submodule add git submodule add 'https://github.com/BradLarson/GPUImage.git' GPUImage //会以最后的参数GPUImgae为名创建文件夹，否者默认为项目
// 下面做常规的git操作
```

二、在项目中引用别的项目
1. 把GPUImage项目工程文件添加到当前工程里，拖进去就可以了
2. 在Build Phases/Target Dependencies中添加GPUImage
3. 在Build Phases/Link Binary With Libraries中添加libGPUImage.a,和其它GPUImage需要的lib
4. 在Build Setting中设置Hearder Search Paths中添加GPUImage/framework,并且选择recursive
5. 在info中添加Application supports iTunes file sharing(or raw UIFileSharingEnabled)，这样就可以在iTunes中查看Documents中的文件

三、GPUImage的逻辑,其实就是类似流水线
```
self.camera = [[[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack] autorelease];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = NO;
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    
    self.filter = [[[GPUImageSepiaFilter alloc] init] autorelease];
    [self.camera addTarget:_filter];//类似流水线，camera作为output，而input到filter中
    
    GPUImageView *filterView = (GPUImageView *)self.view;
    [_filter addTarget:filterView];//类似流水线，_filter作为output，而input到filterView中
```
一个output可以添加多个input，比如后面，filter又添加了一个input:writer
```
self.writer = [[[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)] autorelease];
        [self.filter addTarget:self.writer];
```
而录音的输出只有一个，只能赋值
```
self.camera.audioEncodingTarget = self.writer;
```
详细信息可以参考源代码
clone此代码后，为了使用submodule需要执行
```
git submodule init
git submodule update
```