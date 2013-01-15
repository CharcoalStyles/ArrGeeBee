//Code generated with DAME. http://www.dambots.com

package com.charcoalStyles.rgb.levels;

import nme.display.BitmapInt32;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;

class DAMELevel
{
	// The masterLayer contains every single object in this group making it easy to empty the level.
	public var masterLayer:FlxGroup;

	// This group contains all the tilemaps specified to use collisions.
	public var hitTilemaps:FlxGroup;
	// This group contains all the tilemaps.
	public var tilemaps:FlxGroup;

	public var boundsMinX:Int;
	public var boundsMinY:Int;
	public var boundsMaxX:Int;
	public var boundsMaxY:Int;

	#if flash 
	public var bgColor:UInt;
	#else
	public var bgColor:BitmapInt32;
	#end

	public function new()
	{
		masterLayer = new FlxGroup();
		hitTilemaps = new FlxGroup();
		tilemaps = new FlxGroup();

		bgColor = 0;
	}

	// Expects callback function to be callback(newobj:Object,layer:FlxGroup,level:BaseLevel,properties:Array)
	public function createObjects(onAddCallback:Dynamic = null, parentObject:FlxObject= null):Void{ }

	public function addTilemap(  mapData:String, imageClass:Dynamic, x:Float, y:Float,
		tileWidth:Int, tileHeight:Int, scrollX:Float, scrollY:Float, hits:Bool,
		collideIdx:Int, drawIdx:Int, properties:Array<Dynamic>, onAddCallback:Dynamic = null, autoTilemap:Bool):FlxTilemap
	{
		var map:FlxTilemap = new FlxTilemap();
		map.loadMap( mapData, imageClass, tileWidth, tileHeight, autoTilemap ? FlxTilemap.AUTO : FlxTilemap.OFF, 0, drawIdx, collideIdx);
		map.x = x;
		map.y = y;
		map.scrollFactor.x = scrollX;
		map.scrollFactor.y = scrollY;
		if ( hits )
			hitTilemaps.add(map);
		tilemaps.add(map);
		if(onAddCallback != null)
			onAddCallback(map, null, this, scrollX, scrollY, properties);
		return map;
	}

	public function addSpriteToLayer(obj:FlxSprite, layer:FlxGroup, x:Float, y:Float,
		angle:Float, ?scrollX:Float = 1, ?scrollY:Float = 1, ?flipped:Bool = false, ?scaleX:Float = 1,
		?scaleY:Float= 1, ?properties:Array<Dynamic> = null, ?onAddCallback:Dynamic = null):FlxSprite
	{
		obj.x += x + obj.offset.x;
		obj.y += y + obj.offset.y;
		obj.angle = angle;
		if ( scaleX != 1 || scaleY != 1 )
		{
			obj.scale.x = scaleX;
			obj.scale.y = scaleY;
			obj.width *= scaleX;
			obj.height *= scaleY;
			// Adjust the offset, in case it was already set.
			var newFrameWidth:Float = obj.frameWidth * scaleX;
			var newFrameHeight:Float = obj.frameHeight * scaleY;
			var hullOffsetX:Float = obj.offset.x * scaleX;
			var hullOffsetY:Float = obj.offset.y * scaleY;
			obj.offset.x -= (newFrameWidth- obj.frameWidth) / 2;
			obj.offset.y -= (newFrameHeight - obj.frameHeight) / 2;
		}
		if( obj.facing == FlxObject.RIGHT )
			obj.facing = flipped ? FlxObject.LEFT : FlxObject.RIGHT;
		obj.scrollFactor.x = scrollX;
		obj.scrollFactor.y = scrollY;
		layer.add(obj);
		callbackNewData(obj, onAddCallback, layer, properties, scrollX, scrollY, false);
		return obj;
	}

	public function callbackNewData(data:Dynamic, onAddCallback:Dynamic, layer:FlxGroup,
		properties:Array<Dynamic>, scrollX:Float, scrollY:Float, needsReturnData:Bool = false):Dynamic	{
		if(onAddCallback != null)
		{
			var newData:Dynamic = onAddCallback(data, layer, this, scrollX, scrollY, properties);
			if( newData != null )
				data = newData;
			else if ( needsReturnData )
				trace("Error: callback needs to return either the object passed in or a new object to set up links correctly.");
		}
		return data;
	}

}
