package com.charcoalStyles.rgb;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxText;

/**
 * ...
 * @author Aaron
 */

class LevelIntro extends FlxGroup
{

	public function new(inTitle:String, inSub:String, inMode:Bool) 
	{
		super();
		
		var sprite:FlxSprite;
		var text:FlxText;
		
		//border
		sprite = new FlxSprite(FlxG.width / 4 - (4 * Vars.halfsizeFix), FlxG.height / 3 - (4 * Vars.halfsizeFix));
		sprite.makeGraphic(Std.int(FlxG.width / 2 + (8 * Vars.halfsizeFix)), Std.int(FlxG.height / 3 + (8 * Vars.halfsizeFix)), 0xff000000);
		sprite.scrollFactor = new FlxPoint();
		add(sprite);
		//plate
		sprite = new FlxSprite(FlxG.width / 4, FlxG.height / 3);
		sprite.makeGraphic(Std.int(FlxG.width / 2), Std.int(FlxG.height / 3));
		sprite.scrollFactor = new FlxPoint();
		add(sprite);
		
		//title shadow
		text = new FlxText(Std.int(sprite.x) + 2, Std.int(sprite.y + 8 * Vars.halfsizeFix) + 1, Std.int(sprite.width), inTitle);
		text.setFormat(Vars.fontVisitor, Vars.headingFontSize, 0x202020, "center");
		text.scrollFactor = new FlxPoint();
		add(text);
		//title
		text = new FlxText(Std.int(sprite.x), Std.int(sprite.y + 8 * Vars.halfsizeFix), Std.int(sprite.width), inTitle);
		text.setFormat(Vars.fontVisitor, Vars.headingFontSize, 0xa0a0a0, "center");
		text.scrollFactor = new FlxPoint();
		add(text);
		
		//title shadow
		text = new FlxText(Std.int(sprite.x) + 2, Std.int(sprite.y + 8 * Vars.halfsizeFix + Vars.headingFontSize) + 1, Std.int(sprite.width), inSub);
		text.setFormat(Vars.fontVisitor, Vars.normalFontSize, 0x202020, "center");
		text.scrollFactor = new FlxPoint();
		add(text);
		//title
		text = new FlxText(Std.int(sprite.x), Std.int(sprite.y + 8 * Vars.halfsizeFix + Vars.headingFontSize), Std.int(sprite.width), inSub);
		text.setFormat(Vars.fontVisitor, Vars.normalFontSize, 0xa0a0a0, "center");
		text.scrollFactor = new FlxPoint();
		add(text);
		
	}
	
}