package com.charcoalStyles.rgb;

import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;

/**
 * ...
 * @author Aaron
 */

class Menu extends FlxState
{

	
	public function new() 
	{
		super();
		
	}
	
	override public function create():Void 
	{
		super.create();
		
		if (FlxG.mobile)
			FlxG.mouse.load("assets/null.png");
		else
			FlxG.mouse.show();
		
		var b:FlxSprite = new FlxSprite();
		b.makeGraphic(FlxG.width, FlxG.height);
		add(b);
		
		var title:RgbText = new RgbText(0, 32);
		title.make("ARRGEEBEE", Std.int(Vars.headingFontSize * 1.5));
		add(title);
		
		var text:FlxText = new FlxText(0, FlxG.height - 8- Vars.normalFontSize, FlxG.width, "v0.01");
		text.setFormat(Vars.fontPaskowy, Vars.normalFontSize, 0xcc00cc, "left");
		add(text);
		
		var button:FlxButton = new FlxButton(FlxG.width / 2, FlxG.height  - 64, "Play", onClick);
		button.x = (FlxG.width - button.width) / 2;
		add(button);
		
			
	}
	
	
	private function onClick():Void
	{
		FlxG.switchState(new Game());
	}
	
	
}