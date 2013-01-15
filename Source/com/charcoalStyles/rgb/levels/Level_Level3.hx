//Code generated with DAME. http://www.dambots.com

package com.charcoalStyles.rgb.levels;

import nme.Assets;
import com.vn.core.HDictionary;
import com.skyhammer.entites.ShSprite;
import com.skyhammer.entites.ShEntity;
import com.skyhammer.entites.Switch;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;

class Level_Level3 extends RGBLevel
{
	//Stuff...

	//Tilemaps
	public var layerMap2:FlxTilemap;

	//Sprites
	public var Layer1Group:FlxGroup;

	private var linkedObjects:HDictionary;
		//Properties

	public function new(addToStage:Bool = true, onAddCallback:Dynamic = null, parentObject:Dynamic = null)
	{
		super();
		linkedObjects = new HDictionary();
		// Generate maps.
		layerMap2 = addTilemap( Assets.getText("levels/mapCSV_Level3_Map2.csv"),"assets/WorkingTiles.png" ,0.000, 0.000, 0, 0, 1.000, 1.000, true, 1, 1, null, onAddCallback, false );

		//Add layers to the master group in correct order.
		Layer1Group = new FlxGroup();
		masterLayer.add(Layer1Group);
		masterLayer.add(layerMap2);

		if ( addToStage )
		{
			createObjects(onAddCallback, parentObject);
			generateObjectLinks();
		}

		boundsMinX = 0;
		boundsMinY = 0;
		boundsMaxX = 448;
		boundsMaxY = 320;
		bgColor = 0xff000000;
	}

	override public function createObjects(onAddCallback:Dynamic = null, parentObject:FlxObject = null):Void
	{
		addSpritesForLayerLayer1(onAddCallback);
	}

	public function addSpritesForLayerLayer1(onAddCallback:Dynamic = null):Void
	{
		var obj:com.charcoalStyles.rgb.entities.PlayerSpawn = new com.charcoalStyles.rgb.entities.PlayerSpawn();
		obj.numberOfBlobs = 1;
		addSpriteToLayer(obj, Layer1Group , 64.000, 192.000, 0.000, 1, 1, false, 1.000, 1.000, null, onAddCallback );//"PlayerSpawn"
		var obj:com.charcoalStyles.rgb.entities.LevelEnd = new com.charcoalStyles.rgb.entities.LevelEnd();
		obj.setNumber = 1;
		addSpriteToLayer(obj, Layer1Group , 192.000, 192.000, 0.000, 1, 1, false, 1.000, 1.000, null, onAddCallback );//"LevelEnd"
		var obj:com.charcoalStyles.rgb.entities.LevelData = new com.charcoalStyles.rgb.entities.LevelData();
		obj.title = "Square Dance";
		obj.subTitle = "";
		obj.isAllMove = true;
		addSpriteToLayer(obj, Layer1Group , 160.000, -72.000, 0.000, 1, 1, false, 1.000, 1.000, null, onAddCallback );//"LevelData"
	}

	public function generateObjectLinks(onAddCallback:Dynamic = null):Void
	{
	}
	private function generateTwoWayLink(parentKey:Int, childKey:Int):Void
	{
		var parent:ShEntity = linkedObjects.getValue(parentKey);
		var child:ShEntity = linkedObjects.getValue(childKey);

		if (Std.is(parent, Switch))
		{			var p:Switch = cast(parent, Switch);
			p.children.push(child);

			if (Std.is(child, Switch))
				cast(child, Switch).parents.push(p);
		}
	}

}
