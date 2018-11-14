package zeal;
import leaf.Leaf;
import zeal.Zeal;
import kha.Image;
import kha.Assets;
import trilateralXtra.kDrawing.PolyPainter;
import kha.graphics2.Graphics;

class Zebra {
    public var scale:       Float = 1.;
    public var angle:       Float;
    // initial position
    var x:                  Int;
    var y:                  Int;
	// Zebra body and limbs
    var body:               Leaf;
    var head:               Leaf;
    var neck:               Leaf;
    var chin:               Leaf;
    var tail:               Leaf;
    var backHoff:           Leaf;
    var frontHoff:          Leaf;
    var frontLegTop:        Leaf;
    var backLegTop:         Leaf;
    var frontLegBottom:     Leaf;
    var backLegBottom:      Leaf;  
    var backHoff2:          Leaf;
    var frontHoff2:         Leaf;
    var frontLegTop2:       Leaf;
    var backLegTop2:        Leaf;
    var frontLegBottom2:    Leaf;
    var backLegBottom2:     Leaf;
    // to allow disabling limbs for development ( since less limbs runs faster ).
    var hasNeck:            Bool = true;
    var hasHead:            Bool = true;
    var hasChin:            Bool = true;
    var hasTail:            Bool = true;
    var hasLegs:            Bool = true;
    var hasFrontLegs:       Bool = true;
    var hasBackLegs:        Bool = true;
    public function new(    x_:             Int
                        ,   y_:             Int 
                        ,   scale_:         Float = 1.
                        ){
        angle       = Math.PI;
        x           = x_;
        y           = y_;
        scale       = scale_;
        createSkeleton();
    }
    public inline
    function createSkeleton(){
        var z                   = Assets.images;
        var imageB              = z.body;
        // create Leaf renderers for all the limbs.
        body = new Leaf( imageB, x, y );
        body.scale = scale;
        if( hasNeck ){
            neck = new Leaf( z.neck );
            body.addLeaf( neck, 33, 49 );
            if( hasHead ){
                head = new Leaf( z.head );
                neck.addLeaf( head, 18, 32 );
                if( hasChin ){
                    chin = new Leaf( z.chin );
                    head.addLeaf( chin, 20, 62 );
                }
            }
        }
        if( hasTail ){
            tail = new Leaf( z.tail );
            body.addLeaf( tail, 230, 25 );
        }
        if( hasLegs ){
            if( hasFrontLegs ){
                frontLegTop     = new Leaf( z.frontLegTop );
                frontLegTop2    = new Leaf( z.frontLegTop );
                frontLegBottom  = new Leaf( z.frontLegBottom );
                frontLegBottom2 = new Leaf( z.frontLegBottom );
                frontHoff       = new Leaf( z.frontHoff );
                frontHoff2      = new Leaf( z.frontHoff );
                // put them in order so they pick up correct rank ( not ideal ! )
                body.addLeaf(               frontLegTop,        28, 87      );
                body.addLeaf(               frontLegTop2,       28, 87 - 2  );
                frontLegTop.addLeaf(        frontLegBottom,     35, 95      );
                frontLegTop2.addLeaf(       frontLegBottom2,    35, 95 - 2  );
                frontLegBottom.addLeaf(     frontHoff,          10, 50      );
                frontLegBottom2.addLeaf(    frontHoff2,         10, 50 - 2  );
            }
            if( hasBackLegs ){
                backHoff        = new Leaf( z.backHoff );
                backLegTop      = new Leaf( z.backLegTop );
                backLegBottom   = new Leaf( z.backLegBottom );
                backHoff2       = new Leaf( z.backHoff );
                backLegTop2     = new Leaf( z.backLegTop );
                backLegBottom2  = new Leaf( z.backLegBottom );
                body.addLeaf(               backLegTop,         185, 57     );
                body.addLeaf(               backLegTop2,        185, 57 - 2 );
                backLegTop.addLeaf(         backLegBottom,      47, 75      );
                backLegTop2.addLeaf(        backLegBottom2,     47, 75 - 2  );
                backLegBottom.addLeaf(      backHoff,           10, 55      );
                backLegBottom2.addLeaf(     backHoff2,          10, 55 - 2  );
            }
        }
        setupRotationOffSets(); // must setup rotationOffsets before first render
    }
    inline
    function setupRotationOffSets(){
        var bodyImage = Assets.images.body;
        var bodyCx = bodyImage.width/2;
        var bodyCy = bodyImage.height/2;
        body.rotate( 0, bodyCx, bodyCy );
        if( hasNeck ){
            neck.rotate( 0, 80, 90 );
            if( hasHead ){
                head.rotate( 0, 40, 30 );
                if( hasChin ){
                    chin.rotate( 0, 11, -5 );
                }
            }
        }
        if( hasTail ){
            tail.rotate( 0, 5, 5 );
        }
        if( hasLegs ){
            if( hasFrontLegs ){
                frontHoff.rotate(           0, 15, 0 );
                frontLegBottom.rotate(      0, 10, 10 );
                frontLegTop.rotate(         0, 25, 25 );
                frontHoff2.rotate(          0, 15, 0 );
                frontLegBottom2.rotate(     0, 10, 10 );
                frontLegTop2.rotate(        0, 25, 25 );
            }
            if( hasBackLegs ){
                backHoff.rotate(            0, 15, 0 );
                backLegBottom.rotate(       0, 15, 5 );
                backLegTop.rotate(          0, 23, -8 );
                backHoff2.rotate(           0, 15, 0 );
                backLegBottom2.rotate(      0, 15, 5 );
                backLegTop2.rotate(         0, 23, -8 );
            }
        }
    }
    public inline
    function animateAcross(   polyPainter:  PolyPainter
                          ,   dx:           Int -> Int -> Float -> Int
                          ,   dy:           Int -> Int -> Float -> Int
                          ){
        // clear last Zebra
        // Animate body of Zebra
        runMovement();
        // Move accross screen;
        x                       = dx( x, y, angle );
        y                       = dy( x, y, angle );
        body.x                  = x;
        body.y                  = y;
        // render Zebra on screen
        body.render( polyPainter );
    }
    public function setPosition( x_: Int, y_: Int ){
        x = x_;
        y = y_;
    }
    inline 
    function runMovement(){
        angle += 0.4;
        // adjust angle of limbs, if not adjusted they assume to be just down
        // thier default rotation is not effected by their parent, only the position.
        var sin                 = Math.sin( angle );            
        var cos                 = Math.cos( angle );
        var cos2                = Math.cos( -angle );
        var spi                 = sin*Math.PI;
        var cpi                 = cos*Math.PI;
        //body.updatePosition(); // use if not setting body rotation to make sure updates.
        body.theta              = -Math.PI/50*sin;
        if( hasLegs ){
            if( hasFrontLegs ){
                frontLegTop2.theta      = cpi/7 + Math.PI/14;
                frontLegBottom2.theta   = -Math.PI/10 - cpi/20 ;
                frontLegTop.theta       = Math.PI/7*sin + Math.PI/14;
                frontLegBottom.theta    = -Math.PI/10 - Math.PI/10*sin/2 ;
            }
            if( hasBackLegs ){
                backLegTop2.theta       = Math.PI/10*cos2;
                backLegBottom2.theta    = Math.PI/10 - Math.PI/10*cos2/2 ;
                backLegTop.theta        = spi/10;
                backLegBottom.theta     = Math.PI/10 - Math.PI/10*sin/2 ;
            }
        }
        if( hasTail ) tail.theta              = spi/30;
        if( hasNeck ) {
            neck.theta              = -spi/25;
            if( hasChin ) chin.theta              = spi/20 - Math.PI/10;
        }
    }
}