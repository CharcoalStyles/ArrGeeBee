package com.charcoalStyles.rgb.levels;

import com.charcoalStyles.rgb.BlobMan;
import com.charcoalStyles.rgb.entities.LevelData;
import com.charcoalStyles.rgb.entities.PlayerSpawn;
import com.charcoalStyles.rgb.entities.LevelEnd;
import com.skyhammer.entites.Area;
import com.skyhammer.entites.Physics;
import com.skyhammer.util.SHMath;
import com.skyhammer.entites.ShEntity;
import com.skyhammer.entites.Solid;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;

/**
 * ...
 * @author Aaron
 */

class RGBLevel extends DAMELevel
{
	public var blobs:FlxGroup;
	public var levelEnds:Array<LevelEnd>;

	public var interactiveEntites:FlxGroup;
	public var collidableEntites:FlxGroup;
	
	public var props:LevelData;
	
	public function new() 
	{
		super();
		blobs = new FlxGroup();
		levelEnds = new Array<LevelEnd>();
		
		interactiveEntites = new FlxGroup();
		collidableEntites = new FlxGroup();
	}
	
	override public function addTilemap(mapData:String, imageClass:Dynamic, x:Float, y:Float, tileWidth:Int, tileHeight:Int, scrollX:Float, scrollY:Float, hits:Bool, collideIdx:Int, drawIdx:Int, properties:Array<Dynamic>, onAddCallback:Dynamic = null, autoTilemap:Bool):FlxTilemap 
	{
		return super.addTilemap(mapData, imageClass, x, y, tileWidth, tileHeight, scrollX, scrollY, hits, collideIdx, drawIdx, properties, onAddCallback, autoTilemap);
		
		x *= Vars.halfsizeFix;
		y *= Vars.halfsizeFix;
	}
	
	override public function addSpriteToLayer(obj:FlxSprite, layer:FlxGroup, x:Float, y:Float, angle:Float, ?scrollX:Float = 1, ?scrollY:Float = 1, ?flipped:Bool = false, ?scaleX:Float = 1, ?scaleY:Float = 1, ?properties:Array<Dynamic> = null, ?onAddCallback:Dynamic = null):FlxSprite 
	{
		x *= Vars.halfsizeFix;
		y *= Vars.halfsizeFix;
		
		if (Std.is(obj, LevelData))
			props = cast(obj, LevelData);
		
		if (Std.is(obj, PlayerSpawn))
		{
			var b:BlobMan = new BlobMan();
			b.numberOfBlobs = cast(obj, PlayerSpawn).numberOfBlobs;
			b.reset(x, y);
			blobs.add(b);
		}
		
		if (Std.is(obj, LevelEnd))
		{
			levelEnds.push(cast(obj, LevelEnd));
		}
		
		if (Std.is(obj, Solid))
		{
			collidableEntites.add(obj);
		}
		
		if (Std.is(obj, Area))
		{
			interactiveEntites.add(obj);
		}
		
		return super.addSpriteToLayer(obj, layer, x, y, angle, scrollX, scrollY, flipped, scaleX, scaleY, properties, onAddCallback);
	}
	
	public function update()
	{
		FlxG.collide(blobs, hitTilemaps);
		FlxG.collide(blobs);
		
		FlxG.collide(blobs, collidableEntites, collideObjects);
		FlxG.overlap(blobs, interactiveEntites, overlapObjects);
	}
	
	private function overlapObjects(Object1:FlxObject, Object2:FlxObject):Void {
		if (Std.is(Object1, Area))
			cast(Object1, Area).OverlapArea(Object2);
		else
			cast(Object2, Area).OverlapArea(Object1);
	}
	
	private function collideObjects(Object1:FlxObject, Object2:FlxObject):Void {
		if (Std.is(Object1, Solid))
			cast(Object1, Solid).onHit(Object2);
		else
			cast(Object2, Solid).onHit(Object1);
	}
}