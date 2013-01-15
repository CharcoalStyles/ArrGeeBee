package com.charcoalStyles.rgb;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Aaron
 */

class levelTile extends FlxSprite
{
	private var count:Float;

	public function new(X:Int, Y:Int) 
	{
		super(X,Y);
		makeGraphic(64, 64, 0x4480a0d0);
		count = FlxG.random() * 0.5;
	}
	
	override public function update():Void 
	{
		super.update();
		
		count += FlxG.elapsed;
		if (count >= 0.5)
		{
			count = 0;
		}
			scale = new FlxPoint(1 + count, 1 + count);
	}
}