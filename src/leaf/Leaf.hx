package leaf;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector4;
import trilateral.path.Fine;
import kha.Color;
import trilateral.tri.Triangle;
import trilateral.tri.TriangleArray;
import trilateral.tri.TrilateralArray;
import leaf.DrawTool;
import trilateralXtra.kDrawing.PolyPainter;
using leaf.Leaf;
typedef Point2D = { x: Int, y: Int } 
typedef Axis = { beta: Float, hyp: Float }
class Leaf {
    public var imageAlpha:          Float = 0.7;
    public var scale:               Float = 1.;
    public var rank:                Int = 0;
    public static var showBoxes:    Bool = true;
    public static var showCrosses:  Bool = true;
    public var name:                String;
    public var parent:              Leaf;
    // image position
    public var x:           Int;
    public var y:           Int;
    // image dim
    public var w ( default, null ):    Int;
    public var h ( default, null ):    Int;
    // rotation point
    public var rx:         Float;
    public var ry:         Float;
    // source
    public var image( default, set ):  Image;
    // angle in radians
    public var theta( default, set ): Float;
    // store by depth
    public var leaves:                      Array<Leaf>;
    public var leafCentre:                  Array<Point2D>;
    public var leafAxis:                    Array<Axis>;
    public var left( default, default ):    Int;
    public var top( default, default ):     Int;
    public var wid( default, null ):        Int;
    public var hi( default, null ):         Int;    
    public var cx( default, null ):         Float;
    public var cy( default, null ):         Float;
    public var hyp:                         Float;
    public var beta:                        Float;
    var dx:                                 Float;
    var dy:                                 Float;
    public var offset:                      Point2D;
    public function set_image( image_: Image ): Image {
        image   = image_;
        w       = image.width;
        h       = image.height;
        return image;
    }
    public function set_theta( theta_: Float ): Float {
        if( theta == null ) theta = 0;
        var dTheta = theta - theta_;
        theta = theta_;
        if( rx == null ) rx = 0;
        if( ry == null ) ry = 0;
        var sine            = Math.sin( theta );
        var cos             = Math.cos( theta );
        // new dimensions
        wid                 = Std.int( Math.abs( w*cos ) + Math.abs( h*sine ) );
        hi                  = Std.int( Math.abs( w*sine ) + Math.abs( h*cos ) ); 
        // new centre
        cx                  = wid/2;
        cy                  = hi/2;
        // calculates offset of pivot
        offset              = pivotOffset();
        left                = Std.int( x + offset.x );
        top                 = Std.int( y + offset.y );
        return theta_;
    }
    public inline
    function updatePosition(){
        offset              = pivotOffset();
        left                = Std.int( x + offset.x );
        top                 = Std.int( y + offset.y );
    }
    public function addLeaf( leaf: Leaf, rx_: Int, ry_: Int ){
        if( leaf == null ) return;
        leaf.rank = rank + 1;
        leaf.scale = scale;
        leafCentre.push( { x: rx_, y: ry_ } );
        leaves.push( leaf );
    }
    public function rotate( theta_: Float, rx_: Float, ry_: Float ) {
        rx = rx_;
        ry = ry_;
        theta = theta_;
        for( i in 0...leafCentre.length ){
            if( leafAxis[i] == null ){
                var dx2     = rx - leafCentre[ i ].x;
                var dy2     = ry - leafCentre[ i ].y;
                leafAxis.push( { beta: Math.atan2( dy2, dx2 ), hyp: Math.pow( dx2*dx2 + dy2*dy2, 0.5 ) } ); 
            }
        }
    }
    public function new( image_: Image, x_: Int = 0, y_: Int = 0 ) {
        leaves  = [];
        leafAxis = new Array<Axis>();
        leafCentre = new Array<Point2D>();
        image   = image_;
        x       = x_;
        y       = y_;
    }
    public function pivotOffset(): Point2D {
        var dx      = w/2 - rx;
        var dy      = h/2 - ry;
        // calculates the angle from the old centre to the pivot point.
        beta        = Math.atan2( dy, dx );
        // calculates the diagonal distance from the old centre to the pivot point.
        hyp         = Math.pow( dx*dx + dy*dy, 0.5 );
        var bt      = beta + theta;
        return  {   x: Std.int( rx - cx + hyp*Math.cos( bt ) )
                ,   y: Std.int( ry - cy + hyp*Math.sin( bt ) )
                };
    }
    public function render( polyPainter: PolyPainter ){
        var bt = beta + theta;
        var rotX = left + cx - hyp*Math.cos( bt );
        var rotY = top  + cy - hyp*Math.sin( bt );
        var g = polyPainter.g4;
        var scaleTrans = FastMatrix3.scale( scale, scale );
        var m3 = scaleTrans.multmat( FastMatrix3.translation( left + cx, top + cy ) )
                          .multmat( FastMatrix3.rotation( theta ) )
                          .multmat( FastMatrix3.translation( -w/2, -h/2 ) );
        var m4 = PolyPainter.matrix3to4( m3 );
        var transform = polyPainter.projectionMatrix;
        polyPainter.projectionMatrix = transform.multmat( m4 );
        polyPainter.drawImage( image, 0, 0, w, h, imageAlpha );
        polyPainter.flush();
        if( showBoxes || showCrosses ){
            polyPainter.projectionMatrix = transform.multmat( PolyPainter.matrix3to4( scaleTrans ) );
            if( showBoxes ) DrawTool.addBox(   polyPainter, left, top, wid, hi, DrawTool.idToResistorColor( 7 - rank * 2 ) );
            if( showCrosses ){
                DrawTool.addCross( polyPainter, rotX, rotY, DrawTool.idToResistorColor( (rank-1) * 2 )  );
                DrawTool.addCross( polyPainter, left + cx, top + cy, DrawTool.idToResistorColor( rank * 2 )  );
            }
            polyPainter.flush();
        }
        polyPainter.projectionMatrix = transform;
        for( i in 0...leaves.length ){
            var axis                = leafAxis[ i ];
            var leaf                = leaves[ i ];
            var loff                = leaf.offset;
            var hyp2                = axis.hyp;
            var b2t                 = axis.beta + theta;
            leaf.left = Std.int( rotX - hyp2*Math.cos( b2t ) + loff.x - leaf.rx ) ;
            leaf.top  = Std.int( rotY - hyp2*Math.sin( b2t ) + loff.y - leaf.ry );
            leaves[ i ].render( polyPainter );
        }
    }
}