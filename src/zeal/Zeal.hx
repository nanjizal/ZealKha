package zeal;
import leaf.Leaf;
import zeal.Zebra;
import kha.Image;
import trilateralXtra.kDrawing.PolyPainter;
class Zeal {
    var zebras:               Array<Zebra>;
    static var numberOfZebra: Int;
    var distance: Int = 120;
    public function new( zebraTotal: Int = 3 ){
        numberOfZebra = zebraTotal;
        zebras = [];
        for( i in 0...numberOfZebra ){
            var zebra = new Zebra(  Std.int( 1200 + Math.random()*300 )
                                ,   Std.int( 100+i*30 + 300 )
                                ,   0.75+0.12*i
                                );
            zebra.angle = Math.PI/( Math.random()*8 );
            zebras.push( zebra );
        }
    }
    var count = 0;
    inline 
    public function render( polyPainter: PolyPainter ){
        for( i in 0...numberOfZebra ){ 
            zebras[ i ].animateAcross(    polyPainter
                                    ,     minus13 
                                    ,     upAndDown
                                    );
        }
        count++;
        if( count > distance ) resetZeal();
    }
    function resetZeal(){
        for( i in 0...numberOfZebra ){ 
            zebras[i].setPosition(    Std.int( 1200 + Math.random()*300 )
                                  ,   Std.int( 100+i*30 + 300 )
                                  );
        }
        count = 0;
    }
    inline public
    function minus13( x: Int, y: Int, angle: Float ): Int {
        return x - 13;
    }
    inline public
    function upAndDown( x: Int, y: Int, angle: Float ): Int {
        return y + Std.int( 3*Math.sin( angle/7 ) );
    }
}