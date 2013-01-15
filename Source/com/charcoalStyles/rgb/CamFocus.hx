package com.charcoalStyles.rgb;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Aaron
 */

class CamFocus extends FlxSprite
{

	public function new(minX:Int, minY:Int, maxX:Int, maxY:Int) 
	{
		super();
		makeGraphic(2, 2, 0xaa8080FF);
		updateFrameData();
	}
	
}