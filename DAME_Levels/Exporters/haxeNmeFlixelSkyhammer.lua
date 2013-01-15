

groups = DAME.GetGroups()
groupCount = as3.tolua(groups.length) -1

DAME.SetFloatPrecision(3)

tab1 = "\t"
tab2 = "\t\t"
tab3 = "\t\t\t"
tab4 = "\t\t\t\t"
tab5 = "\t\t\t\t\t"

-- slow to call as3.tolua many times so do as much as can in one go and store to a lua variable instead.
exportOnlyCSV = as3.tolua(VALUE_ExportOnlyCSV)
autoTile = as3.tolua(VALUE_AutoTile)
flixelPackage = as3.tolua(VALUE_FlixelPackage)
haxeNMEAssets = as3.tolua(VALUE_HaxeNMEAssets)
haxeNMELevelAssets = as3.tolua(VALUE_HaxeNMELevelAssets)
baseClassName = as3.tolua(VALUE_BaseClass)
baseExtends = as3.tolua(VALUE_BaseClassExtends)
IntermediateClass = as3.tolua(VALUE_IntermediateClass)
as3Dir = as3.tolua(VALUE_AS3Dir)
tileMapClass = as3.tolua(VALUE_TileMapClass)
GamePackage = as3.tolua(VALUE_GamePackage)
csvDir = as3.tolua(VALUE_CSVDir)
importsText = as3.tolua(VALUE_Imports)

-- This is the file for the map base class
baseFileText = "";
fileText = "";

pathLayers = {}

containsBoxData = false
containsCircleData = false
containsTextData = false
containsPaths = false

------------------------
-- TILEMAP GENERATION
------------------------
function exportMapCSV( mapLayer, layerFileName )
	-- get the raw mapdata. To change format, modify the strings passed in (rowPrefix,rowSuffix,columnPrefix,columnSeparator,columnSuffix)
	mapText = as3.tolua(DAME.ConvertMapToText(mapLayer,"","\n","",",",""))
	DAME.WriteFile(csvDir.."/"..layerFileName, mapText );
end


function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

------------------------
-- PATH GENERATION
------------------------

-- This will store the path along with a name so when we call a get it will output the value between the first : and the last %
-- Here it will be paths[i]. When we later call %getparent% on any attached avatar it will output paths[i].
pathText = "%store:paths[%counter:paths%]%"
pathText = pathText.."%counter++:paths%" -- This line will actually incremement the counter.

lineNodeText = "new FlxPoint(%nodex%, %nodey%)"
splineNodeText = "{ pos:new FlxPoint(%nodex%, %nodey%), tan1:new FlxPoint(%tan1x%, %tan1y%), tan2:new FlxPoint(-(%tan2x%), -(%tan2y%)) }"

propertiesString = "generateProperties( %%proploop%%"
	propertiesString = propertiesString.."{ name:\"%propname%\", value:%propvaluestring% }, "
propertiesString = propertiesString.."%%proploopend%%null )"

tilePropertiesString = "%%ifproplength%%"..tab3.."tileProperties[%tileid%]="..propertiesString..";\n%%endifproplength%%"

local groupPropTypes = as3.toobject({ String="String", Int="int", Float="Number", Boolean="Boolean" })

DAME.SetCurrentPropTypes( groupPropTypes )

linkAssignText = "%%if link%%"
	linkAssignText = linkAssignText..tab2.."linkedObjects.setKey(%linkid%, obj);\n"
linkAssignText = linkAssignText.."%%endiflink%%"
needCallbackText = "%%if link%%, true %%endiflink%%"


function generatePaths( )
	for i,v in ipairs(pathLayers) do	
		containsPaths = true
		fileText = fileText..tab2.."public function addPathsForLayer"..pathLayers[i][3].."(onAddCallback:Function = null):void\n"
		fileText = fileText..tab2.."{\n"
		fileText = fileText..tab3.."var pathobj:PathData;\n\n"

		linesText = pathText..tab3.."pathobj = new PathData( [ %nodelist% \n"..tab3.."], %isclosed%, false, "..pathLayers[i][3].."Group );\n"
		linesText = linesText..tab3.."paths.push(pathobj);\n"

		layer = pathLayers[i][2]
		if flixelVersion == "2.5" then
			linesText = linesText..tab3..linkAssignText.."callbackNewData( pathobj, onAddCallback, "..pathLayers[i][3].."Group, "..propertiesString..", "..as3.tolua(layer.xScroll)..", "..as3.tolua(layer.xScroll)..needCallbackText.." );\n\n"
		else
			linesText = linesText..tab3..linkAssignText.."callbackNewData( pathobj, onAddCallback, "..pathLayers[i][3].."Group, "..propertiesString..needCallbackText.." );\n\n"
		end
		
		fileText = fileText..as3.tolua(DAME.CreateTextForPaths(layer, linesText, lineNodeText, linesText, splineNodeText, ",\n"..tab4))
		fileText = fileText..tab2.."}\n\n"
	end
end

-------------------------------------
-- SHAPE and TEXTBOX GENERATION
-------------------------------------

function generateShapes( )
	for i,v in ipairs(shapeLayers) do	
		groupname = shapeLayers[i][3].."Group"

		if flixelVersion == "2.5" then
			scrollText = ", "..as3.tolua(layer.xScroll)..", "..as3.tolua(layer.yScroll)
		else
			scrollText = ""
		end
		
		textboxText = tab3..linkAssignText.."callbackNewData(new TextData(%xpos%, %ypos%, %width%, %height%, %degrees%, \"%text%\",\"%font%\", %size%, 0x%color%, \"%align%\"), onAddCallback, "..groupname..", "..propertiesString..scrollText..needCallbackText.." ) ;\n"
		
		fileText = fileText..tab2.."public function addShapesForLayer"..shapeLayers[i][3].."(onAddCallback:Function = null):void\n"
		fileText = fileText..tab2.."{\n"
		fileText = fileText..tab3.."var obj:Object;\n\n"
		
		boxText = tab3.."obj = new BoxData(%xpos%, %ypos%, %degrees%, %width%, %height%, "..groupname.." );\n"
		boxText = boxText..tab3.."shapes.push(obj);\n"
		boxText = boxText..tab3..linkAssignText.."callbackNewData( obj, onAddCallback, "..groupname..", "..propertiesString..scrollText..needCallbackText.." );\n"

		circleText = tab3.."obj = new CircleData(%xpos%, %ypos%, %radius%, "..groupname.." );\n"
		circleText = circleText..tab3.."shapes.push(obj);\n"
		circleText = circleText..tab3..linkAssignText.."callbackNewData( obj, onAddCallback, "..groupname..", "..propertiesString..scrollText..needCallbackText..");\n"

		shapeText = as3.tolua(DAME.CreateTextForShapes(shapeLayers[i][2], circleText, boxText, textboxText ))
		fileText = fileText..shapeText
		fileText = fileText..tab2.."}\n\n"
		
		if string.find(shapeText, "BoxData") ~= nil then
			containsBoxData = true
		end
		if string.find(shapeText, "CircleData") ~= nil then
			containsCircleData = true
		end
		if containsTextData == false and string.find(shapeText, "TextData") ~= nil then
			containsTextData = true
		end
	end
end

------------------------
-- BASE CLASS
------------------------
if exportOnlyCSV == false then	
	baseFileText = "//Code generated with DAME. http://www.dambots.com\n\n"
	baseFileText = baseFileText.."package "..GamePackage..";\n\n"
	
	baseFileText = baseFileText.."import nme.display.BitmapInt32;\n"
	baseFileText = baseFileText.."import "..flixelPackage..".FlxGroup;\n"
	baseFileText = baseFileText.."import "..flixelPackage..".FlxObject;\n"
	baseFileText = baseFileText.."import "..flixelPackage..".FlxSprite;\n"
	baseFileText = baseFileText.."import "..flixelPackage..".FlxTilemap;\n\n"
	if # importsText > 0 then
		baseFileText = baseFileText..tab1.."// Custom imports:\n"..importsText.."\n"
	end
	
	baseFileText = baseFileText.."class "..baseClassName
	if # baseExtends > 0 then
		baseFileText = baseFileText.." extends "..baseExtends
	end
	baseFileText = baseFileText.."\n"
	
	baseFileText = baseFileText.."{\n"
	baseFileText = baseFileText..tab1.."// The masterLayer contains every single object in this group making it easy to empty the level.\n"
	baseFileText = baseFileText..tab1.."public var masterLayer:FlxGroup;\n\n"
	baseFileText = baseFileText..tab1.."// This group contains all the tilemaps specified to use collisions.\n"
	baseFileText = baseFileText..tab1.."public var hitTilemaps:FlxGroup;\n"
	baseFileText = baseFileText..tab1.."// This group contains all the tilemaps.\n"
	baseFileText = baseFileText..tab1.."public var tilemaps:FlxGroup;\n\n"
	baseFileText = baseFileText..tab1.."public var boundsMinX:Int;\n"
	baseFileText = baseFileText..tab1.."public var boundsMinY:Int;\n"
	baseFileText = baseFileText..tab1.."public var boundsMaxX:Int;\n"
	baseFileText = baseFileText..tab1.."public var boundsMaxY:Int;\n\n"
	baseFileText = baseFileText..tab1.."#if flash \n"
	baseFileText = baseFileText..tab1.."public var bgColor:UInt;\n"
	baseFileText = baseFileText..tab1.."#else\n"
	baseFileText = baseFileText..tab1.."public var bgColor:BitmapInt32;\n"
	baseFileText = baseFileText..tab1.."#end\n\n"
	--baseFileText = baseFileText..tab1.."public var paths:Array = [];\t// Array of PathData\n"
	--baseFileText = baseFileText..tab1.."public var shapes:Array = [];\t//Array of ShapeData.\n"
	--baseFileText = baseFileText..tab1.."public static var linkedObjectDictionary:Dictionary = new Dictionary;\n\n"
	
	baseFileText = baseFileText..tab1.."public function new()\n"..tab1.."{\n"
	baseFileText = baseFileText..tab2.."masterLayer = new FlxGroup();\n"
	baseFileText = baseFileText..tab2.."hitTilemaps = new FlxGroup();\n"
	baseFileText = baseFileText..tab2.."tilemaps = new FlxGroup();\n\n"
	baseFileText = baseFileText..tab2.."bgColor = 0;\n"
	baseFileText = baseFileText..tab1.."}\n\n"
	
	baseFileText = baseFileText..tab1.."// Expects callback function to be callback(newobj:Object,layer:FlxGroup,level:BaseLevel,properties:Array)\n"
	baseFileText = baseFileText..tab1.."public function createObjects(onAddCallback:Dynamic = null, parentObject:FlxObject= null):Void{ }\n\n"
	
	baseFileText = baseFileText..tab1.."public function addTilemap(  mapData:String, imageClass:Dynamic, x:Float, y:Float,\n"..tab2.."tileWidth:Int, tileHeight:Int, scrollX:Float, scrollY:Float, hits:Bool,\n"..tab2.."collideIdx:Int, drawIdx:Int, properties:Array<Dynamic>, onAddCallback:Dynamic = null, autoTilemap:Bool):"..tileMapClass.."\n"
	baseFileText = baseFileText..tab1.."{\n"
	baseFileText = baseFileText..tab2.."var map:"..tileMapClass.." = new "..tileMapClass.."();\n"
	
	baseFileText = baseFileText..tab2.."map.loadMap( mapData, imageClass, tileWidth, tileHeight, autoTilemap ? FlxTilemap.AUTO : FlxTilemap.OFF, 0, drawIdx, collideIdx);\n"

	baseFileText = baseFileText..tab2.."map.x = x;\n"
	baseFileText = baseFileText..tab2.."map.y = y;\n"
	baseFileText = baseFileText..tab2.."map.scrollFactor.x = scrollX;\n"
	baseFileText = baseFileText..tab2.."map.scrollFactor.y = scrollY;\n"
	baseFileText = baseFileText..tab2.."if ( hits )\n"
	baseFileText = baseFileText..tab3.."hitTilemaps.add(map);\n"
	baseFileText = baseFileText..tab2.."tilemaps.add(map);\n"
	baseFileText = baseFileText..tab2.."if(onAddCallback != null)\n"
	baseFileText = baseFileText..tab3.."onAddCallback(map, null, this, scrollX, scrollY, properties);\n"

	baseFileText = baseFileText..tab2.."return map;\n"
	baseFileText = baseFileText..tab1.."}\n\n"
	
	baseFileText = baseFileText..tab1.."public function addSpriteToLayer(obj:FlxSprite, layer:FlxGroup, x:Float, y:Float,\n"..tab2.."angle:Float, ?scrollX:Float = 1, ?scrollY:Float = 1, ?flipped:Bool = false, ?scaleX:Float = 1,\n"..tab2.."?scaleY:Float= 1, ?properties:Array<Dynamic> = null, ?onAddCallback:Dynamic = null):FlxSprite\n"
	baseFileText = baseFileText..tab1.."{\n"
	baseFileText = baseFileText..tab2.."obj.x += x + obj.offset.x;\n"
	baseFileText = baseFileText..tab2.."obj.y += y + obj.offset.y;\n"
	baseFileText = baseFileText..tab2.."obj.angle = angle;\n"
	baseFileText = baseFileText..tab2.."if ( scaleX != 1 || scaleY != 1 )\n"
	baseFileText = baseFileText..tab2.."{\n"
	baseFileText = baseFileText..tab3.."obj.scale.x = scaleX;\n"
	baseFileText = baseFileText..tab3.."obj.scale.y = scaleY;\n"
	baseFileText = baseFileText..tab3.."obj.width *= scaleX;\n"
	baseFileText = baseFileText..tab3.."obj.height *= scaleY;\n"
	baseFileText = baseFileText..tab3.."// Adjust the offset, in case it was already set.\n"
	baseFileText = baseFileText..tab3.."var newFrameWidth:Float = obj.frameWidth * scaleX;\n"
	baseFileText = baseFileText..tab3.."var newFrameHeight:Float = obj.frameHeight * scaleY;\n"
	baseFileText = baseFileText..tab3.."var hullOffsetX:Float = obj.offset.x * scaleX;\n"
	baseFileText = baseFileText..tab3.."var hullOffsetY:Float = obj.offset.y * scaleY;\n"
	baseFileText = baseFileText..tab3.."obj.offset.x -= (newFrameWidth- obj.frameWidth) / 2;\n"
	baseFileText = baseFileText..tab3.."obj.offset.y -= (newFrameHeight - obj.frameHeight) / 2;\n"
	baseFileText = baseFileText..tab2.."}\n"
	baseFileText = baseFileText..tab2.."if( obj.facing == FlxObject.RIGHT )\n"
	baseFileText = baseFileText..tab3.."obj.facing = flipped ? FlxObject.LEFT : FlxObject.RIGHT;\n"
	baseFileText = baseFileText..tab2.."obj.scrollFactor.x = scrollX;\n"
	baseFileText = baseFileText..tab2.."obj.scrollFactor.y = scrollY;\n"
	baseFileText = baseFileText..tab2.."layer.add(obj);\n"
	baseFileText = baseFileText..tab2.."callbackNewData(obj, onAddCallback, layer, properties, scrollX, scrollY, false);\n"
	
	baseFileText = baseFileText..tab2.."return obj;\n"
	baseFileText = baseFileText..tab1.."}\n\n"
	
	--baseFileText = baseFileText..tab1.."public function addTextToLayer(textdata:TextData, layer:FlxGroup, scrollX:Number, scrollY:Number, embed:Boolean, properties:Array, onAddCallback:Function ):FlxText\n"
	--baseFileText = baseFileText..tab1.."{\n"
	--baseFileText = baseFileText..tab2.."var textobj:FlxText = new FlxText(textdata.x, textdata.y, textdata.width, textdata.text, embed);\n"
	--baseFileText = baseFileText..tab2.."textobj.setFormat(textdata.fontName, textdata.size, textdata.color, textdata.alignment);\n"
	--baseFileText = baseFileText..tab2.."addSpriteToLayer(textobj, FlxText, layer , 0, 0, textdata.angle, scrollX, scrollY, false, 1, 1, properties, onAddCallback );\n"
	--baseFileText = baseFileText..tab2.."textobj.height = textdata.height;\n"
	--baseFileText = baseFileText..tab2.."textobj.origin.x = textobj.width * 0.5;\n"
	--baseFileText = baseFileText..tab2.."textobj.origin.y = textobj.height * 0.5;\n"
	--baseFileText = baseFileText..tab2.."return textobj;\n"
	--baseFileText = baseFileText..tab1.."}\n\n"
	
	baseFileText = baseFileText..tab1.."public function callbackNewData(data:Dynamic, onAddCallback:Dynamic, layer:FlxGroup,\n"..tab2.."properties:Array<Dynamic>, scrollX:Float, scrollY:Float, needsReturnData:Bool = false):Dynamic"
	baseFileText = baseFileText..tab1.."{\n"
	baseFileText = baseFileText..tab2.."if(onAddCallback != null)\n"
	baseFileText = baseFileText..tab2.."{\n"
	baseFileText = baseFileText..tab3.."var newData:Dynamic = onAddCallback(data, layer, this, scrollX, scrollY, properties);\n"
	baseFileText = baseFileText..tab3.."if( newData != null )\n"
	baseFileText = baseFileText..tab4.."data = newData;\n"
	baseFileText = baseFileText..tab3.."else if ( needsReturnData )\n"
	baseFileText = baseFileText..tab4.."trace(\"Error: callback needs to return either the object passed in or a new object to set up links correctly.\");\n"
	baseFileText = baseFileText..tab2.."}\n"
	baseFileText = baseFileText..tab2.."return data;\n"
	baseFileText = baseFileText..tab1.."}\n\n"
--	
	--baseFileText = baseFileText..tab2.."protected function generateProperties( ... arguments ):Array\n"
--	baseFileText = baseFileText..tab2.."{\n"
	--baseFileText = baseFileText..tab3.."var properties:Array = [];\n"
--	baseFileText = baseFileText..tab3.."if ( arguments.length )\n"
	--baseFileText = baseFileText..tab3.."{\n"
--	baseFileText = baseFileText..tab4.."for( var i:uint = 0; i < arguments.length-1; i++ )\n"
	--baseFileText = baseFileText..tab4.."{\n"
--	baseFileText = baseFileText..tab5.."properties.push( arguments[i] );\n"
	--baseFileText = baseFileText..tab4.."}\n"
--	baseFileText = baseFileText..tab3.."}\n"
	--baseFileText = baseFileText..tab3.."return properties;\n"
--	baseFileText = baseFileText..tab2.."}\n\n"
	--
--	baseFileText = baseFileText..tab2.."public function createLink( objectFrom:Object, target:Object, onAddCallback:Function, properties:Array ):void\n"
	--baseFileText = baseFileText..tab2.."{\n"
--	baseFileText = baseFileText..tab3.."var link:ObjectLink = new ObjectLink( objectFrom, target );\n"
	--if flixelVersion == "2.5" then
		--baseFileText = baseFileText..tab3.."callbackNewData(link, onAddCallback, null, properties, objectFrom.scrollFactor.x, objectFrom.scrollFactor.y);\n"
	--else
		--baseFileText = baseFileText..tab3.."callbackNewData(link, onAddCallback, null, properties);\n"
	--end
--	baseFileText = baseFileText..tab2.."}\n\n"
	--
--	baseFileText = baseFileText..tab2
	--if baseExtends == "FlxGroup" then
		--baseFileText = baseFileText.."override "
	--end
--	baseFileText = baseFileText.."public function destroy():void\n"
	--baseFileText = baseFileText..tab2.."{\n"
--	baseFileText = baseFileText..tab3.."masterLayer.destroy();\n"
	--baseFileText = baseFileText..tab3.."masterLayer = null;\n"
--	baseFileText = baseFileText..tab3.."tilemaps = null;\n"
	--baseFileText = baseFileText..tab3.."hitTilemaps = null;\n\n"
			--
	--baseFileText = baseFileText..tab3.."var i:uint;\n"
--	baseFileText = baseFileText..tab3.."for ( i = 0; i < paths.length; i++ )\n"
	--baseFileText = baseFileText..tab3.."{\n"
--	baseFileText = baseFileText..tab4.."var pathobj:Object = paths[i];\n"
	--baseFileText = baseFileText..tab4.."if ( pathobj )\n"
--	baseFileText = baseFileText..tab4.."{\n"
	--baseFileText = baseFileText..tab5.."pathobj.destroy();\n"
--	baseFileText = baseFileText..tab4.."}\n"
	--baseFileText = baseFileText..tab3.."}\n"
--	baseFileText = baseFileText..tab3.."paths = null;\n\n"
			--
	--baseFileText = baseFileText..tab3.."for ( i = 0; i < shapes.length; i++ )\n"
--	baseFileText = baseFileText..tab3.."{\n"
	--baseFileText = baseFileText..tab4.."var shape:Object = shapes[i];\n"
--	baseFileText = baseFileText..tab4.."if ( shape )\n"
	--baseFileText = baseFileText..tab4.."{\n"
--	baseFileText = baseFileText..tab5.."shape.destroy();\n"
	--baseFileText = baseFileText..tab4.."}\n"
--	baseFileText = baseFileText..tab3.."}\n"
	--baseFileText = baseFileText..tab3.."shapes = null;\n"
--	baseFileText = baseFileText..tab2.."}\n\n"
--
	baseFileText = baseFileText.."}\n"		-- end package
	DAME.WriteFile(as3Dir.."/"..baseClassName..".hx", baseFileText )
end

------------------------
-- GROUP CLASSES
------------------------
for groupIndex = 0,groupCount do

	maps = {}
	spriteLayers = {}
	shapeLayers = {}
	pathLayers = {}
	masterLayerAddText = ""
	stageAddText = ""
	
	group = groups[groupIndex]
	groupName = as3.tolua(group.name)
	groupName = string.gsub(groupName, " ", "_")
	
	DAME.ResetCounters()
	
	layerCount = as3.tolua(group.children.length) - 1
	
	-- This is the file for the map group class.
	fileText = "//Code generated with DAME. http://www.dambots.com\n\n"
	fileText = fileText.."package "..GamePackage..";\n"
	fileText = fileText.."\n"
	fileText = fileText.."import nme.Assets;\n"
	fileText = fileText.."import com.vn.core.HDictionary;\n"
	fileText = fileText.."import com.skyhammer.entites.ShSprite;\n"
	fileText = fileText.."import com.skyhammer.entites.ShEntity;\n"
	fileText = fileText.."import com.skyhammer.entites.Switch;\n"
	fileText = fileText.."import "..flixelPackage..".FlxGroup;\n"
	fileText = fileText.."import "..flixelPackage..".FlxObject;\n"
	fileText = fileText.."import "..flixelPackage..".FlxSprite;\n"
	fileText = fileText.."import "..flixelPackage..".FlxTilemap;\n\n"
	
	if # importsText > 0 then
		fileText = fileText.."// Custom imports:\n"..importsText.."\n"
	end
	fileText = fileText.."class Level_"..groupName.." extends "
	if # IntermediateClass > 0 then
		fileText = fileText..IntermediateClass.."\n"
	else
		fileText = fileText..baseClassName.."\n"
	end
	
	fileText = fileText.."{\n"
	fileText = fileText..tab1.."//Stuff...\n"
	
	layerImageFile = ""; -- to store the image file name
	-- Go through each layer and store some tables for the different layer types.
	for layerIndex = 0,layerCount do
		layer = group.children[layerIndex]
		isMap = as3.tolua(layer.map)~=nil
		layerName = as3.tolua(layer.name)
		layerName = string.gsub(layerName, " ", "_")
		if isMap == true then
			mapFileName = "mapCSV_"..groupName.."_"..layerName..".csv"
			-- Generate the map file.
			exportMapCSV( layer, mapFileName )
			
			-- This needs to be done here so it maintains the layer visibility ordering.
			if exportOnlyCSV == false then
				table.insert(maps,{layer,layerName})
				-- For maps just generate the Embeds needed at the top of the class.
				--fileText = fileText..tab2.."[Embed(source=\""..as3.tolua(DAME.GetRelativePath(as3Dir, csvDir.."/"..mapFileName)).."\", mimeType=\"application/octet-stream\")] public var CSV_"..layerName..":Class;\n"
				--fileText = fileText..tab2.."[Embed(source=\""..as3.tolua(DAME.GetRelativePath(as3Dir, layer.imageFile)).."\")] public var Img_"..layerName..":Class;\n"
				layerImageFile = as3.tolua(layer.imageFile);
				masterLayerAddText = masterLayerAddText..tab2.."masterLayer.add(layer"..layerName..");\n"
			end

		elseif exportOnlyCSV == false then
			addGroup = false;
			if as3.tolua(layer.IsSpriteLayer()) == true then
				masterLayerAddText = masterLayerAddText..tab2..layerName.."Group = new FlxGroup();\n";
				table.insert( spriteLayers,{groupName,layer,layerName})
				addGroup = true;
				stageAddText = stageAddText..tab2.."addSpritesForLayer"..layerName.."(onAddCallback);\n"
			--elseif as3.tolua(layer.IsShapeLayer()) == true then
				--table.insert(shapeLayers,{groupName,layer,layerName})
				--addGroup = true
			--elseif as3.tolua(layer.IsPathLayer()) == true then
				--table.insert(pathLayers,{groupName,layer,layerName})
				--addGroup = true
			end
			
			if addGroup == true then
				masterLayerAddText = masterLayerAddText..tab2.."masterLayer.add("..layerName.."Group);\n"
			end
		end
	end

	-- Generate the actual text for the derived class file.
	
	if exportOnlyCSV == false then

		------------------------------------
		-- VARIABLE DECLARATIONS
		-------------------------------------
		fileText = fileText.."\n"
		
		if # maps > 0 then
			fileText = fileText..tab1.."//Tilemaps\n"
			for i,v in ipairs(maps) do
				fileText = fileText..tab1.."public var layer"..maps[i][2]..":"..tileMapClass..";\n"
			end
			fileText = fileText.."\n"
		end
		
		if # spriteLayers > 0 then
			fileText = fileText..tab1.."//Sprites\n"
			for i,v in ipairs(spriteLayers) do
				fileText = fileText..tab1.."public var "..spriteLayers[i][3].."Group:FlxGroup;\n"
			end
			fileText = fileText.."\n"
		end
		
		fileText = fileText..tab1.."private var linkedObjects:HDictionary;\n"
		
		--if # shapeLayers > 0 then
			--fileText = fileText..tab2.."//Shapes\n"
--			for i,v in ipairs(shapeLayers) do
				--fileText = fileText..tab2.."public var "..shapeLayers[i][3].."Group:FlxGroup = new FlxGroup;\n"
			--end
--			fileText = fileText.."\n"
		--end
--		
		--if # pathLayers > 0 then
			--fileText = fileText..tab2.."//Paths\n"
--			for i,v in ipairs(pathLayers) do
				--fileText = fileText..tab2.."public var "..pathLayers[i][3].."Group:FlxGroup = new FlxGroup;\n"
			--end
--			fileText = fileText.."\n"
		--end
		
		--groupPropertiesString = "%%proploop%%"..tab2.."public var %propnamefriendly%:%proptype% = %propvaluestring%;\n%%proploopend%%"
		
		fileText = fileText..tab2.."//Properties\n"
		--fileText = fileText..as3.tolua(DAME.GetTextForProperties( groupPropertiesString, group.properties, groupPropTypes )).."\n"
		
		fileText = fileText.."\n"
		fileText = fileText..tab1.."public function new(addToStage:Bool = true, onAddCallback:Dynamic = null, parentObject:Dynamic = null)\n"
		fileText = fileText..tab1.."{\n"
		fileText = fileText..tab2.."super();\n"
		fileText = fileText..tab2.."linkedObjects = new HDictionary();\n"
		fileText = fileText..tab2.."// Generate maps.\n"
		
		--fileText = fileText..tab2.."var properties:Array = [];\n"
		--fileText = fileText..tab2.."var tileProperties:Dictionary = new Dictionary;\n\n"
		
		minx = 9999999
		miny = 9999999
		maxx = -9999999
		maxy = -9999999
		-- Create the tilemaps.
		for i,v in ipairs(maps) do
			layerName = maps[i][2]
			layer = maps[i][1]
			
			x = as3.tolua(layer.map.x)
			y = as3.tolua(layer.map.y)
			width = as3.tolua(layer.map.width)
			height = as3.tolua(layer.map.height)
			xscroll = as3.tolua(layer.xScroll)
			yscroll = as3.tolua(layer.yScroll)
			hasHitsString = ""
			if as3.tolua(layer.HasHits) == true then
				hasHitsString = "true"
			else
				hasHitsString = "false"
			end
			
			--fileText = fileText..tab2.."properties = "..as3.tolua(DAME.GetTextForProperties( propertiesString, layer.properties ))..";\n"
			tileData = as3.tolua(DAME.CreateTileDataText( layer, tilePropertiesString, "", ""))
			if # tileData > 0 then
				fileText = fileText..tileData
				--fileText = fileText..tab2.."properties.push( { name:\"%DAME_tiledata%\", value:tileProperties } );\n"
			end
			fileText = fileText..tab2.."layer"..layerName.." = addTilemap( Assets.getText(\""..haxeNMELevelAssets.."/mapCSV_"..groupName.."_"..layerName..".csv\"),\""..haxeNMEAssets.."/"..string.gsub(layerImageFile, '.*\\', '').."\" ,"..string.format("%.3f",x)..", "..string.format("%.3f",y)..", 0, 0, "..string.format("%.3f",xscroll)..", "..string.format("%.3f",yscroll)..", "..hasHitsString..", "..as3.tolua(layer.map.collideIndex)..", "..as3.tolua(layer.map.drawIndex)..", null, onAddCallback, "..tostring(autoTile).." );\n"

			-- Only set the bounds based on maps whose scroll factor is the same as the player's.
			if xscroll == 1 and yscroll == 1 then
				if x < minx then minx = x end
				if y < miny then miny = y end
				if x + width > maxx then maxx = x + width end
				if y + height > maxy then maxy = y + height end
			end
			
		end
		
		------------------
		-- MASTER GROUP.
		------------------
		
		fileText = fileText.."\n"..tab2.."//Add layers to the master group in correct order.\n"
		fileText = fileText..masterLayerAddText.."\n";
		
		fileText = fileText..tab2.."if ( addToStage )\n"
		fileText = fileText..tab2.."{\n"
		fileText = fileText..tab3.."createObjects(onAddCallback, parentObject);\n"
		fileText = fileText..tab3.."generateObjectLinks();\n"
		fileText = fileText..tab2.."}\n\n"
		
		fileText = fileText..tab2.."boundsMinX = "..minx..";\n"
		fileText = fileText..tab2.."boundsMinY = "..miny..";\n"
		fileText = fileText..tab2.."boundsMaxX = "..maxx..";\n"
		fileText = fileText..tab2.."boundsMaxY = "..maxy..";\n"
		
		fileText = fileText..tab2.."bgColor = "..as3.tolua(DAME.GetBackgroundColor())..";\n"
		
		fileText = fileText..tab1.."}\n\n"	-- end constructor
		
		---------------
		-- OBJECTS
		---------------
		-- One function for each layer.
		
		fileText = fileText..tab1.."override public function createObjects(onAddCallback:Dynamic = null, parentObject:FlxObject = null):Void\n"
		fileText = fileText..tab1.."{\n"
		-- Must add the paths before the sprites as the sprites index into the paths array.
		--for i,v in ipairs(pathLayers) do
			--fileText = fileText..tab3.."addPathsForLayer"..pathLayers[i][3].."(onAddCallback);\n"
		--end
--		for i,v in ipairs(shapeLayers) do
			--fileText = fileText..tab3.."addShapesForLayer"..shapeLayers[i][3].."(onAddCallback);\n"
		--end
		fileText = fileText..stageAddText
--		fileText = fileText..tab3.."generateObjectLinks(onAddCallback);\n"
		--fileText = fileText..tab3.."if ( parentObject != null )\n"
--		fileText = fileText..tab4.."parentObject.add(masterLayer);\n"
		--fileText = fileText..tab3.."else\n"
--		fileText = fileText..tab4.."FlxG.state.add(masterLayer);\n"
		fileText = fileText..tab1.."}\n\n"
		
		-- Create the paths first so that sprites can reference them if any are attached.
		
		--generatePaths()
--		generateShapes()
		
		-- create the sprites.
		
		for i,v in ipairs(spriteLayers) do
			layer = spriteLayers[i][2]
			creationText = tab2.."%%if parent%%"
				creationText = creationText.."%getparent%.childSprite = "
			creationText = creationText.."%%endifparent%%"
			creationText = creationText.."var obj:%class% = new %class%();\n"
			creationText = creationText.."%%proploop%%"
				creationText = creationText..tab2.."obj.%propname% = %propvaluestring%;\n"
			creationText = creationText.."%%proploopend%%"
			creationText = creationText..tab2.."addSpriteToLayer(obj, "..spriteLayers[i][3].."Group , %xpos%, %ypos%, %degrees%, "..as3.tolua(layer.xScroll)..", "..as3.tolua(layer.xScroll)..", %flipped%, %scalex%, %scaley%, null, onAddCallback );//%name%\n" 
			creationText = creationText..linkAssignText
			
			creationText = creationText.."%%if parent%%"
				creationText = creationText..tab2.."%getparent%.childAttachNode = %attachedsegment%;\n"
				creationText = creationText..tab2.."%getparent%.childAttachT = %attachedsegment_t%;\n"
			creationText = creationText.."%%endifparent%%"
			
			fileText = fileText..tab1.."public function addSpritesForLayer"..spriteLayers[i][3].."(onAddCallback:Dynamic = null):Void\n"
			fileText = fileText..tab1.."{\n"
			fileText = fileText..as3.tolua(DAME.CreateTextForSprites(layer,creationText,"Avatar"))
			fileText = fileText..tab1.."}\n\n"
		end
		
		-- Create the links between objects.
		
		fileText = fileText..tab1.."public function generateObjectLinks(onAddCallback:Dynamic = null):Void\n"
		fileText = fileText..tab1.."{\n"
		--linkText = tab2.."createLink(linkedObjectDictionary[%linkfromid%], linkedObjectDictionary[%linktoid%], onAddCallback, "..propertiesString.." );\n"
		linkText = tab2.."generateTwoWayLink(%linkfromid%, %linktoid%);\n"
		fileText = fileText..as3.tolua(DAME.GetTextForLinks(linkText,group))
		fileText = fileText..tab1.."}\n"
		
		-- Helper to link the objects
		fileText = fileText..tab1.."private function generateTwoWayLink(parentKey:Int, childKey:Int):Void\n"
		fileText = fileText..tab1.."{\n"
		fileText = fileText..tab2.."var parent:ShEntity = linkedObjects.getValue(parentKey);\n"
		fileText = fileText..tab2.."var child:ShEntity = linkedObjects.getValue(childKey);\n\n"
		fileText = fileText..tab2.."if (Std.is(parent, Switch))\n"..tab2.."{"
		fileText = fileText..tab3.."var p:Switch = cast(parent, Switch);\n"
		fileText = fileText..tab3.."p.children.push(child);\n\n"
		fileText = fileText..tab3.."if (Std.is(child, Switch))\n"
		fileText = fileText..tab4.."cast(child, Switch).parents.push(p);\n"
		fileText = fileText..tab2.."}\n"
		fileText = fileText..tab1.."}\n"
		
		
		
		fileText = fileText.."\n"
		fileText = fileText.."}\n"		-- end package
		
		
			
		-- Save the file!
		
		DAME.WriteFile(as3Dir.."/Level_"..groupName..".hx", fileText )
		
	end
end

-- Create any extra required classes.
-- must be done last after the parser has gone through.
-- Not happening, right now...
if exportOnlyCSV == false then

	--if containsTextData == true then
		textfile = "package "..GamePackage.."\n"
		textfile = textfile.."{\n"
		textfile = textfile..tab1.."public class TextData\n"
		textfile = textfile..tab1.."{\n"
		textfile = textfile..tab2.."public var x:Number;\n"
		textfile = textfile..tab2.."public var y:Number;\n"
		textfile = textfile..tab2.."public var width:uint;\n"
		textfile = textfile..tab2.."public var height:uint;\n"
		textfile = textfile..tab2.."public var angle:Number;\n"
		textfile = textfile..tab2.."public var text:String;\n"
		textfile = textfile..tab2.."public var fontName:String;\n"
		textfile = textfile..tab2.."public var size:uint;\n"
		textfile = textfile..tab2.."public var color:uint;\n"
		textfile = textfile..tab2.."public var alignment:String;\n\n"
		textfile = textfile..tab2.."public function TextData( X:Number, Y:Number, Width:uint, Height:uint, Angle:Number, Text:String, FontName:String, Size:uint, Color:uint, Alignment:String )\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."x = X;\n"
		textfile = textfile..tab3.."y = Y;\n"
		textfile = textfile..tab3.."width = Width;\n"
		textfile = textfile..tab3.."height = Height;\n"
		textfile = textfile..tab3.."angle = Angle;\n"
		textfile = textfile..tab3.."text = Text;\n"
		textfile = textfile..tab3.."fontName = FontName;\n"
		textfile = textfile..tab3.."size = Size;\n"
		textfile = textfile..tab3.."color = Color;\n"
		textfile = textfile..tab3.."alignment = Alignment;\n"
		textfile = textfile..tab2.."}\n"
		textfile = textfile..tab1.."}\n"
		textfile = textfile.."}\n"
		
		DAME.WriteFile(as3Dir.."/TextData.as", textfile )
	--end
	
	if containsPaths == true then
		textfile = "package "..GamePackage.."\n"
		textfile = textfile.."{\n"
		textfile = textfile..tab1.."import "..flixelPackage..".FlxGroup;\n"
		textfile = textfile..tab1.."import "..flixelPackage..".FlxSprite;\n\n"
		textfile = textfile..tab1.."public class PathData\n"
		textfile = textfile..tab1.."{\n"
		textfile = textfile..tab2.."public var nodes:Array;\n"
		textfile = textfile..tab2.."public var isClosed:Boolean;\n"
		textfile = textfile..tab2.."public var isSpline:Boolean;\n"
		textfile = textfile..tab2.."public var layer:FlxGroup;\n\n"
		textfile = textfile..tab2.."// These values are only set if there is an attachment.\n"
		textfile = textfile..tab2.."public var childSprite:FlxSprite = null;\n"
		textfile = textfile..tab2.."public var childAttachNode:int = 0;\n"
		textfile = textfile..tab2.."public var childAttachT:Number = 0;\t// position of child between attachNode and next node.(0-1)\n\n"
		textfile = textfile..tab2.."public function PathData( Nodes:Array, Closed:Boolean, Spline:Boolean, Layer:FlxGroup )\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."nodes = Nodes;\n"
		textfile = textfile..tab3.."isClosed = Closed;\n"
		textfile = textfile..tab3.."isSpline = Spline;\n"
		textfile = textfile..tab3.."layer = Layer;\n"
		textfile = textfile..tab2.."}\n\n"
		textfile = textfile..tab2.."public function destroy():void\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."layer = null;\n"
		textfile = textfile..tab3.."childSprite = null;\n"
		textfile = textfile..tab3.."nodes = null;\n"
		textfile = textfile..tab2.."}\n"
		textfile = textfile..tab1.."}\n"
		textfile = textfile.."}\n"
		
		DAME.WriteFile(as3Dir.."/PathData.as", textfile )
		
	end
	
	if containsBoxData == true or containsCircleData == true then
		textfile = "package "..GamePackage.."\n"
		textfile = textfile.."{\n"
		textfile = textfile..tab1.."import "..flixelPackage..".FlxGroup;\n\n"
		textfile = textfile..tab1.."public class ShapeData\n"
		textfile = textfile..tab1.."{\n"
		textfile = textfile..tab2.."public var x:Number;\n"
		textfile = textfile..tab2.."public var y:Number;\n"
		textfile = textfile..tab2.."public var group:FlxGroup;\n\n"
		textfile = textfile..tab2.."public function ShapeData(X:Number, Y:Number, Group:FlxGroup )\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."x = X;\n"
		textfile = textfile..tab3.."y = Y;\n"
		textfile = textfile..tab3.."group = Group;\n"
		textfile = textfile..tab2.."}\n\n"
		textfile = textfile..tab2.."public function destroy():void\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."group = null;\n"
		textfile = textfile..tab2.."}\n"
		textfile = textfile..tab1.."}\n"
		textfile = textfile.."}\n"
		
		DAME.WriteFile(as3Dir.."/ShapeData.as", textfile )
	end
	
	if containsBoxData == true then
		textfile = "package "..GamePackage.."\n"
		textfile = textfile.."{\n"
		textfile = textfile..tab1.."import "..flixelPackage..".FlxGroup;\n\n"
		textfile = textfile..tab1.."public class BoxData extends ShapeData\n"
		textfile = textfile..tab1.."{\n"
		textfile = textfile..tab2.."public var angle:Number;\n"
		textfile = textfile..tab2.."public var width:uint;\n"
		textfile = textfile..tab2.."public var height:uint;\n\n"
		textfile = textfile..tab2.."public function BoxData( X:Number, Y:Number, Angle:Number, Width:uint, Height:uint, Group:FlxGroup ) \n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."super(X, Y, Group);\n"
		textfile = textfile..tab3.."angle = Angle;\n"
		textfile = textfile..tab3.."width = Width;\n"
		textfile = textfile..tab3.."height = Height;\n"
		textfile = textfile..tab2.."}\n"
		textfile = textfile..tab1.."}\n"
		textfile = textfile.."}\n"
		
		DAME.WriteFile(as3Dir.."/BoxData.as", textfile )
	end
	
	if containsCircleData == true then
		textfile = "package "..GamePackage.."\n"
		textfile = textfile.."{\n"
		textfile = textfile..tab1.."import "..flixelPackage..".FlxGroup;\n\n"
		textfile = textfile..tab1.."public class CircleData extends ShapeData\n"
		textfile = textfile..tab1.."{\n"
		textfile = textfile..tab2.."public var radius:Number;\n\n"
		textfile = textfile..tab2.."public function CircleData( X:Number, Y:Number, Radius:Number, Group:FlxGroup )\n"
		textfile = textfile..tab2.."{\n"
		textfile = textfile..tab3.."super(X, Y, Group);\n"
		textfile = textfile..tab3.."radius = Radius;\n"
		textfile = textfile..tab2.."}\n"
		textfile = textfile..tab1.."}\n"
		textfile = textfile.."}\n"
		
		DAME.WriteFile(as3Dir.."/CircleData.as", textfile )
	end
	
	textfile = "package "..GamePackage.."\n"
	textfile = textfile.."{\n"
	textfile = textfile..tab1.."public class ObjectLink\n"
	textfile = textfile..tab1.."{\n"
	textfile = textfile..tab2.."public var fromObject:Object;\n"
	textfile = textfile..tab2.."public var toObject:Object;\n"
	textfile = textfile..tab2.."public function ObjectLink(from:Object, to:Object)\n"
	textfile = textfile..tab2.."{\n"
	textfile = textfile..tab3.."fromObject = from;\n"
	textfile = textfile..tab3.."toObject = to;\n"
	textfile = textfile..tab2.."}\n\n"
	textfile = textfile..tab2.."public function destroy():void\n"
	textfile = textfile..tab2.."{\n"
	textfile = textfile..tab3.."fromObject = null;\n"
	textfile = textfile..tab3.."toObject = null;\n"
	textfile = textfile..tab2.."}\n"
	textfile = textfile..tab1.."}\n"
	textfile = textfile.."}\n"
	--DAME.WriteFile(as3Dir.."/ObjectLink.as", textfile ) --Not today, willis
end




return 1

