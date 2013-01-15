package com.charcoalStyles.rgb;
import com.skyhammer.util.SHEmitter;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxText;

/**
 * ...
 * @author Aaron
 */

class BlobMan extends FlxSprite
{
	private var emitter:SHEmitter;
	
	private static inline var vel:Int = 400;
	private static inline var acel:Int = 1000;
	
	public var isMoving:Bool;
	public var isPushed:Bool;
	
	private var numBlobs:Int;
	
	private var num:FlxText;
	private var numS:FlxText;
	
	public function new() 
	{
		super();
		makeGraphic(Std.int(62 * Vars.halfsizeFix), Std.int(62 * Vars.halfsizeFix));
		
		/*emitter = new SHEmitter();
		emitter.makeParticles("assets/data/logo.png", 20);
		emitter.setLifespan(2.75, 5.25);
		emitter.setScale(1,1,1,1);
		emitter.setAlpha(0.5, 0.75, 0, 0);
		emitter.setVelocity( -5, 5, -5, 5);
		emitter.start(0.2);*/
		
		isMoving = false;
		isPushed = false;
		
		
		num = new FlxText(0, 0, Std.int(width));
		num.setFormat(null, 16, 0xFF00FF);
		numS = new FlxText(0, 0, Std.int(width));
		numS.setFormat(null, 16, 0x0);
		
		numBlobs = 1;
	}
	
	
	override public function update():Void 
	{
		super.update();
		if (velocity.x == 0 && velocity.y == 0)
		{
			acceleration = new FlxPoint();
			isMoving = false;
			isPushed = false;
		}
		
		num.text = Std.string(numBlobs);
		num.x = x;
		num.y = y;
		num.update();
		num.text = Std.string(numBlobs);
		numS.x = x + 2;
		numS.y = y + 2;
		numS.update();
		
		/*emitter.setPosition(x, y);
		emitter.update();*/
	}
	
	override public function draw():Void 
	{
		super.draw();
		//emitter.draw();
		numS.draw();
		num.draw();
	}
	
	public function move(dir:Int):Void
	{
		if (!isMoving)
		{
			isMoving = true;
			velocity = new FlxPoint();
			acceleration = new FlxPoint();
			switch(dir)
			{
				case 1: //up
					velocity.y = -vel;
					acceleration.y = -acel;
				case 2: //down
					velocity.y = vel;
					acceleration.y = acel;
				case 3: //left
					velocity.x = -vel;
					acceleration.x = -acel;
				case 4: //right
					velocity.x = vel;
					acceleration.x = acel;
					
			}
		}
	}
	
	private function setNumberOfBlobs(value:Int):Int
	{
		numBlobs = value;
		
		return value;
	}
	private function getNumberOfBlobs():Int
	{
		return numBlobs;
	}
	
	public var numberOfBlobs(getNumberOfBlobs, setNumberOfBlobs):Int;
}