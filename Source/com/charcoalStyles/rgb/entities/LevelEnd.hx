package com.charcoalStyles.rgb.entities;
import com.charcoalStyles.rgb.BlobMan;
import com.skyhammer.entites.Area;
import org.flixel.FlxObject;
import org.flixel.FlxText;

/**
 * ...
 * @author Aaron
 */

class LevelEnd extends Area
{
	public var isComplete:Bool;
	
	private var numberOfBlobs:Int;
	
	private var num:FlxText;
	private var numS:FlxText;

	public function new() 
	{
		super();
		isComplete = false;
		bitmapString = "assets/LevelEnd.png";
		
		num = new FlxText(0, 0, Std.int(width));
		num.setFormat(null, 16, 0x00FFFF);
		numS = new FlxText(0, 0, Std.int(width));
		numS.setFormat(null, 16, 0x0);
		numberOfBlobs = 1;
	}
	
	override public function update():Void 
	{
		super.update();
		
		num.text = Std.string(numberOfBlobs);
		num.x = x;
		num.y = y;
		num.update();
		numS.text = Std.string(numberOfBlobs);
		numS.x = x + 2;
		numS.y = y + 2;
		numS.update();
	}
	
	override public function OnEnter(object:FlxObject):Void 
	{
		super.OnEnter(object);
		
		
		if (Std.is(object, BlobMan))
		{
			var blob:BlobMan = cast(object, BlobMan);
			if (blob.numberOfBlobs == numberOfBlobs && !blob.isMoving)
				isComplete = true;
		}
	}
	
	override public function draw():Void 
	{
		super.draw();
		numS.draw();
		num.draw();
	}
	
	private function setNumberOfBlobs(value:Int):Int
	{
		numberOfBlobs = value;
		
		return value;
	}
	
	public var setNumber(null, setNumberOfBlobs):Int;
}