package com.charcoalStyles.rgb.entities;
import com.charcoalStyles.rgb.BlobMan;
import com.skyhammer.entites.Area;
import com.skyhammer.util.SHMath;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;

/**
 * ...
 * @author Aaron
 */

class Pusher extends Area
{
	private var moveDir:Int;
	
	private var pushed:Bool;
	
	public function new() 
	{
		super();
		pushed = false;
	}
	
	override public function OnExit(object:FlxObject):Void 
	{
		super.OnExit(object);
		pushed = false;
	}
	
	override public function OverlapArea(object:FlxObject):Void 
	{
		super.OverlapArea(object);
		
		var b:BlobMan = cast(object, BlobMan);
		if (SHMath.getDistance(this, object)< 10 && !b.isPushed)
		{
			b.isPushed = true;
			b.x = x;
			b.y = y;
			
			b.isMoving = false;
			
			b.move(moveDir);
		}
	}
	
	private function set_dir(value:Int):Int
	{
		moveDir = value;
		
		switch(value)
		{
			case 1:
				bitmapString = "assets/Arrow_up.png";
			case 2:
				bitmapString = "assets/Arrow_down.png";
			case 3:
				bitmapString = "assets/Arrow_left.png";
			case 4:
				bitmapString = "assets/Arrow_right.png";
		}
			
		return value;
	}
	
	public var setDir(null, set_dir):Int;
}