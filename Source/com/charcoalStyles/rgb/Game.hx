package com.charcoalStyles.rgb;
import com.charcoalStyles.rgb.levels.LevelSelector;
import com.charcoalStyles.rgb.levels.RGBLevel;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;
import org.flixel.system.FlxTile;
import org.flixel.FlxU;

/**
 * ...
 * @author Aaron
 */

class Game extends FlxState
{
	var currentLevel:RGBLevel;
	
	var mouseDownPos:FlxPoint;
	var movingBM:BlobMan;
	
	var currentState:Int;
	
	var levelIntro:LevelIntro;
	
	var cameraFocus:CamFocus;
	
	public function new() 
	{
		super();
		
	}
	
	override public function create():Void 
	{
		super.create();
		
		currentLevel = LevelSelector.singleton.getNextLevel();
		add(currentLevel.masterLayer);
		
		currentLevel.boundsMaxX = Std.int(currentLevel.boundsMaxX * Vars.halfsizeFix);
		currentLevel.boundsMaxY = Std.int(currentLevel.boundsMaxY * Vars.halfsizeFix);
		
		add(currentLevel.blobs);
		
		add(currentLevel.interactiveEntites);
				
		cameraFocus = new CamFocus(currentLevel.boundsMinX, currentLevel.boundsMinY, currentLevel.boundsMaxX, currentLevel.boundsMaxY);
		add(cameraFocus);
		
		if (currentLevel.boundsMaxX < FlxG.width)
		{
			cameraFocus.x = currentLevel.boundsMaxX / 2;
		}
		if ( currentLevel.boundsMaxY < FlxG.height)
		{
			cameraFocus.y = currentLevel.boundsMaxY / 2;
		}
		
		mouseDownPos = new FlxPoint();
		movingBM = null;
		
		levelIntro = new LevelIntro(currentLevel.props.title, currentLevel.props.subTitle, true);
		add(levelIntro);
		
		currentState = 1;
	}
	
	override public function update():Void
	{
		super.update();
		
		switch (currentState)
		{
			case 1: //splash
				if (FlxG.keys.any() || FlxG.mouse.justPressed())
				{
					currentState++;
					remove(levelIntro, true);
				}
			case 2: //game
		}
		
		updateControls();
		
		currentLevel.update();
		
		var fin:Bool = true;
		for (le in currentLevel.levelEnds)
			if (!le.isComplete)
				fin = false;
		
		if (fin)
		{
			if (LevelSelector.singleton.isOnLastLevel())
				FlxG.switchState(new Menu());
			else
				FlxG.switchState(new Game());
		}
		
		FlxG.camera.focusOn(new FlxPoint(cameraFocus.x, cameraFocus.y));
	}
	
	private function updateControls():Void 
	{
		//key control
		if (FlxG.keys.justPressed("UP"))
		{
			for (b in currentLevel.blobs.members)
				cast(b, BlobMan).move(1);
		}
		if (FlxG.keys.justPressed("DOWN"))
		{
			for (b in currentLevel.blobs.members)
				cast(b, BlobMan).move(2);
		}
		if (FlxG.keys.justPressed("LEFT"))
		{
			for (b in currentLevel.blobs.members)
				cast(b, BlobMan).move(3);
		}
		if (FlxG.keys.justPressed("RIGHT"))
		{
			for (b in currentLevel.blobs.members)
				cast(b, BlobMan).move(4);
		}
		
		//mouse control
		if (FlxG.mouse.justPressed())
		{
			for (b in currentLevel.blobs.members)
			{
				var obj:BlobMan = cast(b, BlobMan);
				if (FlxU.getDistance(new FlxPoint(obj.x + (obj.width / 2), obj.y + (obj.height / 2)), FlxG.mouse.getWorldPosition()) < obj.width / 2)
				{
					mouseDownPos = FlxG.mouse.getWorldPosition();
					movingBM = obj;
				}
			}
		}
		else if (FlxG.mouse.justReleased())
		{
			if (movingBM != null)
			{
				var mouseUpPos:FlxPoint = FlxG.mouse.getWorldPosition();
				if (FlxU.getDistance(mouseDownPos, mouseUpPos) > 5)
				{
					var magX:Float = mouseUpPos.x - mouseDownPos.x;
					var magY:Float = mouseUpPos.y - mouseDownPos.y;
					
					if (Math.abs(magX) > Math.abs(magY)) //horizontal movement
					{
						if (magX > 0) //right
							movingBM.move(4);
						else //left
							movingBM.move(3);
					}
					else //vertica movement
					{
						if (magY > 0) //down
							movingBM.move(2);
						else //up
							movingBM.move(1);
					}
				}
				movingBM = null;
			}
		}
	}
}