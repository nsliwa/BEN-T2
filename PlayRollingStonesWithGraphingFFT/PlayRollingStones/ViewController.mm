//
//  ViewController.m
//  PlayRollingStones
//
//  Created by Eric Larson on 2/5/14.
//  Copyright (c) 2014 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "Novocaine.h"
#import "AudioFileReader.h"
#import "RingBuffer.h"
#import "SMUGraphHelper.h"
#import "SMUFFTHelper.h"


#define kBufferLength 4096
#define kEquilizerBufferLength 20
#define kframesPerSecond 30
#define knumDataArraysToGraph 3

@interface ViewController ()

@property (strong, nonatomic) Novocaine *audioManager;
@property (nonatomic)RingBuffer *ringBuffer;
@property (nonatomic)GraphHelper *graphHelper;
@property (nonatomic)float *audioData;

@property (nonatomic)float *equilizerData;

@property (nonatomic)SMUFFTHelper *fftHelper;
@property (nonatomic)float *fftMagnitudeBuffer;
@property (nonatomic)float *fftPhaseBuffer;

@end

@implementation ViewController

/*
Novocaine *audioManager;
AudioFileReader *fileReader;
RingBuffer *ringBuffer;
GraphHelper *graphHelper;
float *audioData;
SMUFFTHelper *fftHelper;
float *fftMagnitudeBuffer;
float *fftPhaseBuffer;
 */

-(Novocaine*) audioManager {
    if(!_audioManager)
        _audioManager = [Novocaine audioManager];
    return _audioManager;
}
-(RingBuffer*) ringBuffer {
    if(!_ringBuffer)
        _ringBuffer = new RingBuffer(kBufferLength,2);
    return _ringBuffer;
}
-(GraphHelper*) graphHelper {
    if(!_graphHelper) {
        _graphHelper = new GraphHelper(self,
                                       kframesPerSecond,
                                       knumDataArraysToGraph,
                                       PlotStyleSeparated);
    }
    return _graphHelper;
}
-(float*) audioData {
    if(!_audioData)
        _audioData = (float*)calloc(kBufferLength,sizeof(float));
    return _audioData;
}

-(float*) equilizerData {
    if(!_equilizerData)
        _equilizerData = (float*)calloc(kBufferLength,sizeof(float));
    return _equilizerData;
}
-(SMUFFTHelper*) fftHelper {
    if(!_fftHelper)
        _fftHelper = new SMUFFTHelper(kBufferLength,kBufferLength,WindowTypeRect);
    return _fftHelper;
}
-(float*) fftMagnitudeBuffer {
    if(!_fftMagnitudeBuffer)
        _fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    return _fftMagnitudeBuffer;
}
-(float*) fftPhaseBuffer {
    if(!_fftPhaseBuffer)
        _fftPhaseBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    return _fftPhaseBuffer;
}




/*
-(SMUFFTHelper*) fftHelper {
 
}
*/
#pragma mark - loading and appear
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //audioManager = [Novocaine audioManager];
    //ringBuffer = new RingBuffer(kBufferLength,2);
    
    //audioData = (float*)calloc(kBufferLength,sizeof(float));
    
    //setup the fft
    //fftHelper = new SMUFFTHelper(kBufferLength,kBufferLength,WindowTypeRect);
    //fftMagnitudeBuffer = (float *)calloc(kBufferLength/2,sizeof(float));
    //fftPhaseBuffer     = (float *)calloc(kBufferLength/2,sizeof(float));
    
    
    // start animating the graph
    //int framesPerSecond = 30;
    //int numDataArraysToGraph = 2;
    /*graphHelper = new GraphHelper(self,
                                  framesPerSecond,
                                  numDataArraysToGraph,
                                  PlotStyleSeparated);//drawing starts immediately after call
     */
    
    self.graphHelper->SetBounds(-0.9,0.9,-0.9,0.9); // bottom, top, left, right, full screen==(-1,1,-1,1)
    
    [self.audioManager play];
    

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         if(self.ringBuffer!=nil)
             self.ringBuffer->AddNewFloatData(data, numFrames);
     }];
    
//    __block float frequency = 261.0; //starting frequency
//    __block float phase = 0.0;
//    __block float samplingRate = audioManager.samplingRate;
//    
//    [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//     {
//         
//         double phaseIncrement = 2*M_PI*frequency/samplingRate;
//         double repeatMax = 2*M_PI;
//         for (int i=0; i < numFrames; ++i)
//         {
//             for(int j=0;j<numChannels;j++){
//                 data[i*numChannels+j] = 0.8*sin(phase);
//                 
//             }
//             phase += phaseIncrement;
//             
//             if(phase>repeatMax)
//                 phase -= repeatMax;
//         }
//
//         
//     }];

}

#pragma mark - unloading and dealloc
-(void) viewDidDisappear:(BOOL)animated{
    // stop opengl from running
    self.graphHelper->tearDownGL();
    [self.audioManager pause];
}

-(void)dealloc{
    self.graphHelper->tearDownGL();
    
    free(self.audioData);
    free(self.equilizerData);
    
    free(self.fftMagnitudeBuffer);
    free(self.fftPhaseBuffer);
    
    delete self.fftHelper;
    delete self.ringBuffer;
    delete self.graphHelper;
    
    self.ringBuffer = nil;
    self.fftHelper  = nil;
    self.audioManager = nil;
    self.graphHelper = nil;
    
    
    // ARC handles everything else, just clean up what we used c++ for (calloc, malloc, new)
    
}


#pragma mark - OpenGL and Update functions
//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.graphHelper->draw(); // draw the graph
}


//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    // plot the audio
    self.ringBuffer->FetchFreshData2(self.audioData, kBufferLength, 0, 1);
    self.graphHelper->setGraphData(0,self.audioData,kBufferLength); // set graph channel
    
    //take the FFT
    self.fftHelper->forward(0,self.audioData, self.fftMagnitudeBuffer, self.fftPhaseBuffer);
    
    // plot the FFT
    self.graphHelper->setGraphData(1,self.fftMagnitudeBuffer,kBufferLength/8,sqrt(kBufferLength)); // set graph channel
    
    self.graphHelper->update(); // update the graph
}

#pragma mark - status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
