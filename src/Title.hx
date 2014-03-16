using Common;

class Title {

	var game : Game;
	var root : SPR;
	var cursor : SPR;
	var load : Bool;
	var time : Float;
	var layer2 : flash.display.Bitmap;
	var layer3 : flash.display.Bitmap;
	var started : Bool;
	
	public function new( game : Game ) {
		time = 0;
		this.game = game;
		root = new SPR();
		root.scaleX = root.scaleY = 2;
		game.root.addChild(root);
		
		var but = new SPR();
		but.graphics.beginFill(0, 0);
		but.graphics.drawRect(100, 100, 100, 80);
		but.addEventListener(flash.events.MouseEvent.CLICK, function(_) start());
		but.buttonMode = but.mouseEnabled = true;
		but.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(_) {
			var k = root.mouseY < 140;
			if( load == k && game.hasSave() ) {
				Sounds.play("menu");
				load = !k;
			}
		});
		
		var bmp = new flash.display.Bitmap(openfl.Assets.getBitmapData ("title.png"));
		root.addChild(bmp);
		
		#if flash
		// Force transparency
		var title2 = openfl.Assets.getBitmapData("title2.png");
		var data = new flash.display.BitmapData(title2.width, title2.height, true, 0);
		data.copyPixels(title2, title2.rect, new flash.geom.Point ());
		data.floodFill(0, 0, 0);
		title2 = data;
		layer2 = new flash.display.Bitmap(title2);
		root.addChild(layer2);
		
		var title3 = openfl.Assets.getBitmapData("title3.png");
		var data = new flash.display.BitmapData(title3.width, title3.height, true, 0);
		data.copyPixels(title3, title3.rect, new flash.geom.Point ());
		data.floodFill(0, 0, 0);
		title3 = data;
		layer3 = new flash.display.Bitmap(title3);
		root.addChild(layer3);
		#else
		layer2 = new flash.display.Bitmap(openfl.Assets.getBitmapData ("title2.png"));
		layer2.bitmapData.floodFill(0, 0, 0);
		root.addChild(layer2);
		
		layer3 = new flash.display.Bitmap(openfl.Assets.getBitmapData ("title3.png"));
		layer3.bitmapData.floodFill(0, 0, 0);
		root.addChild(layer3);
		#end
		
		var start = game.makeField("Start", 15);
		start.x = 120;
		start.y = 120;
		start.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, start_onClick);
		start.mouseEnabled = true;
		root.addChild(start);
		
		var cont = game.makeField("Continue", 15);
		cont.x = 120;
		cont.y = 140;
		if( !game.hasSave() ) {
			cont.textColor = 0x808080;
		} else {
			cont.mouseEnabled = true;
			cont.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, cont_onClick);
		}
		root.addChild(cont);
		
		var quote = game.makeField("A short story of adventure video games evolution", 10);
		quote.textColor = 0xD8CB55;
		quote.x = 15;
		quote.y = 80;
		root.addChild(quote);
		
		var copy = game.makeField("(C)1986-2012 NCA", 12);
		copy.x = 190;
		copy.y = 188;
		root.addChild(copy);
		
		load = game.hasSave();
		cursor = new SPR();
		cursor.addChild(new flash.display.Bitmap(Entity.sprites[Type.enumIndex(Entity.EKind.Cursor)][0]));
		root.addChild(cursor);

		root.addChild(but);
		root.addEventListener(flash.events.Event.ENTER_FRAME, update);
		Key.init();
		update(null);
	}
	
	function start_onClick(_) {
		load = false;
		start();
	}
	
	function cont_onClick(_) {
		load = true;
		start();
	}
	
	function update(_) {
		for( k in [K.DOWN, K.UP, "Z".code, "W".code, "S".code] )
			if( Key.isToggled(k) && game.hasSave() ) {
				Sounds.play("menu");
				load = !load;
			}
		time += 0.2;
		
		var d2 = time * 2;
		if( d2 > 50 ) d2 = 50 - Math.abs(Math.sin((time - 25) * 0.2) * 2.5);
		layer2.y = 100 - d2 * 2;
		layer2.x = 25 - d2 * 0.5;
		
		layer3.y = Math.sin(time * 0.1) * 10;
		
		cursor.x = 105 + Math.sin(time) * 2;
		cursor.y = 120 + (load ? 20 : 0);
		for( k in ["E".code, K.ENTER, K.SPACE] )
			if( Key.isToggled(k) ) {
				haxe.Timer.delay(start, 10);
				return;
			}
	}
	
	function start() {
		if( started )
			return;
		started = true;
		if( !load )
			Game.props = Game.DEF_PROPS;
		root.stage.focus = root.stage;
		root.removeEventListener(flash.events.Event.ENTER_FRAME,update);
		root.remove();
		game.init();
	}
	
}