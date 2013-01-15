-- Display the settings for the exporter.

DAME.AddHtmlTextLabel("Ensure you use the <b>ComplexClaws</b> PlayState.as file in the samples as the template for any code.")
DAME.AddBrowsePath("HX dir:","AS3Dir",false, "Where you place the Actionscript files.")
DAME.AddBrowsePath("CSV dir:","CSVDir",false)

DAME.AddTextInput("Base Class", "BaseLevel", "BaseClass", true, "What to call the base class that all levels will extend." )
DAME.AddTextInput("Base Class Extends", "", "BaseClassExtends", true, "If you put something here the base class will extend from it." )
DAME.AddTextInput("Intermediate Class", "", "IntermediateClass", true, "This is an optional class which levels will extend from and must extend from the base class." )
DAME.AddTextInput("Game package", "com", "GamePackage", true, "package for your game's .as files." )
DAME.AddTextInput("Flixel package", "org.flixel", "FlixelPackage", true, "package use for flixel .as files." )
DAME.AddTextInput("Haxe NME Asset 'level' folder", "levels", "HaxeNMELevelAssets", true, "The rename of the folder that holds the CSVs" )
DAME.AddTextInput("Haxe NME Asset 'assets' folder", "assets", "HaxeNMEAssets", true, "The rename of the folder that holds the rest of the assets" )
DAME.AddTextInput("TileMap class", "FlxTilemap", "TileMapClass", true, "Base class used for tilemaps." )
DAME.AddMultiLineTextInput("Imports", "", "Imports", 50, true, "Imports for each level class file go here" )
DAME.AddCheckbox("Export only CSV","ExportOnlyCSV",false,"If ticked then the script will only export the map CSV files and nothing else.")
DAME.AddCheckbox("Auto Tile","AutoTile",false,"Set to use Flixel's auo tile feature on all tilemaps.")

return 1
