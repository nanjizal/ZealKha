package leaf;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import trilateral.path.Fine;
import trilateral.path.Base;
import kha.Color;
import trilateral.tri.Triangle;
import trilateral.tri.TriangleArray;
import trilateral.tri.TrilateralArray;
import trilateralXtra.kDrawing.PolyPainter;
import trilateral.polys.Poly;
@:enum
abstract ResistorColors ( Int ) from Int to Int {
       var Black  = 0xaa443D44;
       var Brown  = 0xaa764817;
       var Red    = 0xaaEA4041;
       var Orange = 0xaaF8BC64;
       var Yellow = 0xaaFFE700;
       var Green  = 0xaa39A14A;
       var Blue   = 0xaa00ADE0;
       var Violet = 0xaa62529D;
       var Grey   = 0xaa8B9499;
       var White  = 0xaaFFFFFF;
       var Gold   = 0xaaBF9424;
       var Silver = 0xaaD8DCDD;
       var Band4background = 0xaaD7C6B4;
       var Band5background = 0xaa00A7D1;
}
class DrawTool {
    public static 
    var colorBands = [ Black, Brown, Red, Orange, Yellow, Green, Blue, Violet, Grey, White /* Colors */
                     , Gold, Silver /* tolerances */
                     , Band4background, Band5background /* Resistor base colors */
                     ]; 
    public static
    var id: Int = 0; // increments every time added
    public static inline
    function getPath( width: Float = 3 ): Fine {
        var path = new Fine( null, null, both );
        path.width = width;
        return path;
    }
    public static inline
    function getColorFromTri( tri: Triangle ): Color {
        return getColor( tri.colorID );
    }
    public static inline
    function getColor( id: Int ): Color {
        return Color.fromValue ( colorBands[ id ] );
    }
    public static inline 
    function idToResistorColor( id: Int ){
        return colorBands[ id ];
    }
    public static inline
    function getColorId( resistorColor: ResistorColors ){
        var out: Int = 0;
        for( i in 0...colorBands.length ){
            if( colorBands[ i ] == resistorColor ){
                out = i;
                break;
            }
        }
        return out;
    }
    public static inline
    function render( polyPainter: PolyPainter, triangles: TriangleArray ){
        var tri: Triangle;
        for( i in 0...triangles.length ){
            tri = triangles[ i ];
            polyPainter.drawFillTriangle( tri.ax, tri.ay, tri.bx, tri.by, tri.cx, tri.cy, getColorFromTri( tri ) );
        }
    }
    public static inline
    function pathToTriangles( path: Base, colorId: Int ): TriangleArray {
        var triangles = new TriangleArray();
        triangles.addArray( id, path.trilateralArray, colorId );
        id++;
        return triangles;
    }
    public static inline
    function addCross( polyPainter: PolyPainter
                     , x: Float, y: Float
                     , resistorColor: ResistorColors = Red, thickness: Float = 2 ): TriangleArray{
        var path = getPath( thickness );
        cross( path, x, y );
        var triangles = pathToTriangles( path, getColorId( resistorColor ) );
        render( polyPainter, triangles );
        //triangles = null;
        path = null;
        return triangles;
    }
    // default to Red
    public static inline
    function addBox(  polyPainter: PolyPainter
                    , x: Float, y: Float, w: Float, h: Float
                    , resistorColor: ResistorColors = Red, thickness: Float = 2 ): TriangleArray {
        var path = getPath( thickness );
        box( path, x, y, w, h );
        var triangles = pathToTriangles( path, getColorId( resistorColor ) );
        render( polyPainter, triangles );
        //triangles = null;
        path = null;
        return triangles;
    }
    public static inline 
    function cross( path: Base
                  , x: Float, y: Float ){
        path.moveTo( x - 5, y );
        path.lineTo( x + 5, y );
        path.moveTo( x, y - 5 );
        path.lineTo( x, y + 5 );
    }
    public static inline 
    function box( path: Base
                , left: Float, top: Float, wid: Float, hi: Float ){          
        path.trilateralArray.addArray( Poly.roundedRectangleOutline( left, top, wid, hi, path.width, 12 ) );
    }
    public static inline
    function offsetRotation( angle: Float, centreX: Float, centreY: Float ): FastMatrix3 {
        return FastMatrix3.translation( centreX, centreY )
                          .multmat( FastMatrix3.rotation( angle ) )
                          .multmat( FastMatrix3.translation( -centreX, -centreY ) );
    }
}