package com.charcoalStyles.rgb;
import org.flixel.FlxObject;
import org.flixel.FlxText;
import org.flixel.FlxG;

/**
 * ...
 * @author Aaron
 */

class RgbText extends FlxObject
{

	private var rText:FlxText;
	private var gText:FlxText;
	private var bText:FlxText;
	private var wText:FlxText;
	
	private var rCounter:Float;
	private var gCounter:Float;
	private var bCounter:Float;
	
	private var rxmod:Float;
	private var rxmul:Float;
	private var rymod:Float;
	private var rymul:Float;
	
	private var gxmod:Float;
	private var gxmul:Float;
	private var gymod:Float;
	private var gymul:Float;
	
	private var bxmod:Float;
	private var bxmul:Float;
	private var bymod:Float;
	private var bymul:Float;
	
	private var hasSetup:Bool;
	
	private var originalY:Int;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y);
		hasSetup = false;
		originalY = Y;
	}
	
	public function make(message:String, size:Int):Void
	{
		rText = new FlxText(x, y, FlxG.width, message);
		rText.setFormat(Vars.fontVisitor, size, 0xff4444, "center");
		rText.alpha = 0.4;
		gText = new FlxText(x, y, FlxG.width, message);
		gText.setFormat(Vars.fontVisitor, size, 0x44ff44, "center");
		gText.alpha = 0.4;
		bText = new FlxText(x, y, FlxG.width, message);
		bText.setFormat(Vars.fontVisitor, size, 0x4444ff, "center");
		bText.alpha = 0.4;
		
		wText = new FlxText(x, y, FlxG.width, message);
		wText.setFormat(Vars.fontVisitor, size, 0xffffff, "center");
		
		rxmod = getMod();
		rxmul = getMul(size);
		rymod = getMod();
		rymul = getMul(size);
		
		gxmod = getMod();
		gxmul = getMul(size);
		gymod = getMod();
		gymul = getMul(size);
		
		bxmod = getMod();
		bxmul = getMul(size);
		bymod = getMod();
		bymul = getMul(size);
		
		rCounter = FlxG.random() * 90;
		gCounter = FlxG.random() * 90;
		bCounter = FlxG.random() * 90;
		hasSetup = true;
	}
	
	override public function update():Void 
	{
		super.update();
		if (hasSetup)
		{
			rCounter += FlxG.elapsed * 1.5;
			gCounter += FlxG.elapsed * 1.5;
			bCounter += FlxG.elapsed * 1.5;
			
			rText.x = Math.sin(rCounter * rxmod) * rxmul;
			rText.y = originalY + Math.cos(rCounter * rymod) * rymul;
			
			gText.x = Math.cos(gCounter * gxmod) * gxmul;
			gText.y = originalY + Math.cos(gCounter * gymod) * gymul;
			
			bText.x = Math.sin(bCounter * bxmod) * bxmul;
			bText.y = originalY + Math.cos(bCounter * bymod) * bymul;
		}
	}
	
	override public function draw():Void 
	{
		super.draw();
		if (hasSetup)
		{
			rText.draw();
			bText.draw();
			gText.draw();
			wText.draw();
		}
	}
	
	private function getMod():Float
	{
		return 1 + (FlxG.random() * 2 - 1) / 2;
	}
	
	private function getMul(size:Int):Float
	{
		return ((FlxG.random()/ 10) + 0.05)  * size;
	}
}