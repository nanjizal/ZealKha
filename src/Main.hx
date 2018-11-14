package;
import kha.Framebuffer;
import kha.System;
import kha.Image;
import kha.Color;
import kha.Assets;
import kha.Scaler;
import kha.Color;
import kha.Font;
import kha.Assets;
import kha.Scheduler;
import kha.graphics2.Graphics;
import kha.graphics4.DepthStencilFormat;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.KeyCode;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.WindowOptions;
import kha.WindowMode;
//import kha.Window;
import zeal.Zeal;
import leaf.Leaf;
import leaf.DrawTool;
import trilateralXtra.kDrawing.PolyPainter;
import trilateralXtra.kDrawing.SceneXtras;
class Main {
    var showTimer:       Bool = false;
    var zeal:            Zeal;
    var polyPainter:     PolyPainter;
    var zealImage:       Image;
    public var font:     Font;
    public var previous: Float;
    public var realTime: Float;
    public var transform: FastMatrix4;
    public static 
    function main() {
        System.init( {  title: "ZealKha demo"
                    ,  width: 1024, height: 768
                    ,  samplesPerPixel: 4 }
                    , function(){ new Main();
        } );
        /*System.start( {  title: "ZealKha demo" /* newer kha setup *//*
                             ,  width: 1024, height: 768
                             ,  window: { windowFeatures:    FeatureResizable }
                             , framebuffer: { samplesPerPixel: 4 } }
                             , function( window: Window ){
                                new Main();
        } );*/
    }
    public function new(){ Assets.loadEverything( loadAll ); }
    public function loadAll(){
        trace( 'loadAll' );
        font      = Assets.fonts.OpenSans_Regular;
        previous  = 0.0;
        realTime  = 0.0;
        var zebraTotal = 3;
        zeal      = new Zeal( zebraTotal );
        zealImage = Image.createRenderTarget( 1024, 768, null, DepthStencilFormat.NoDepthAndStencil, 4 );
        polyPainter = new PolyPainter();
        transform = polyPainter.projectionMatrix;
        startRendering();
        initInputs();
    }
    function startRendering(){
        //System.notifyOnFrames( function ( framebuffer ) { render( framebuffer[0] ); } ); // newer Kha setup
        System.notifyOnRender( function ( framebuffer ) { render( framebuffer ); } );
        Scheduler.addTimeTask(update, 0, 1 / 60);
    }
    var lastFps: Float = 0;
    inline
    function render( framebuffer: Framebuffer ){
        renderZeal();
        var g2 = framebuffer.g2;
        g2.begin( Color.Black );
        if( showTimer ) renderTimer( g2 );
        g2.drawImage( zealImage, 0, 0 );
        g2.end();
    }
    inline
    function renderZeal(){
        var p    = polyPainter;
        p.canvas = zealImage;
        p.begin( ImageMode, true, Color.fromValue( 0xFF20200c ) );
        transform = polyPainter.projectionMatrix;
        polyPainter.projectionMatrix = transform.multmat( FastMatrix4.scale( 1.5, 0.7, 1 ) );
        SceneXtras.sky( p );
        p.flush();
        polyPainter.projectionMatrix = transform;
        zeal.render( p );
        p.end();
    }
    inline 
    function renderTimer( g2: Graphics ){
        var fps = 1.0 / ( realTime - previous );
        if( fps != Math.POSITIVE_INFINITY ){
            fps = Math.round( ( fps )*100 )/100;
            lastFps = fps;
        } else {
            fps = lastFps;
        }
        g2.font = font;
        g2.fontSize = 32;
        g2.color = Color.White;
        g2.drawString( Std.string( fps ), 10, 10 );
    }
    inline
    function update(): Void {
        previous = realTime;
        realTime = Scheduler.realTime();
    }
    function initInputs() {
        if (Mouse.get() != null) Mouse.get().notify( mouseDown, mouseUp, mouseMove, mouseWheel );
        if( Keyboard.get() != null ) Keyboard.get().notify( keyDown, keyUp, null );
    }
    function keyDown( keyCode: Int ): Void {
        trace('keydown ' + keyCode );
    }
    function keyUp( keyCode: Int ): Void { 
        trace('keyup ' + keyCode );
    }
    function mouseDown( button: Int, x: Int, y: Int ): Void {
        trace('down');
    }
    function mouseUp( button: Int, x: Int, y: Int ): Void {
        trace('up');
    }
    function mouseMove( x: Int, y: Int, movementX: Int, movementY: Int ): Void {
        trace('Move');
    }
    function mouseWheel( delta: Int ): Void {
        trace('Wheel');
    }
}