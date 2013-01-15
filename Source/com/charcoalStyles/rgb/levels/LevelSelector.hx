package com.charcoalStyles.rgb.levels;

/**
 * ...
 * @author Aaron
 */

class LevelSelector 
{
	private static var sing:LevelSelector;
	//private static var isMade:Bool = false;
	
	private var curLevelIndex:Int;
	
	public function new() 
	{
		curLevelIndex = 0;
	}
	
	public function getNextLevel():RGBLevel
	{
		curLevelIndex++;
		switch(curLevelIndex)
		{
			case 1:
				return new Level_Level1();
			case 2:
				return new Level_Level2();
			case 3:
				return new Level_Level3();
			case 4:
				return new Level_Level4();
			default:
				return new Level_Level1();
		}
	}
	
	public function isOnLastLevel():Bool
	{
		if (curLevelIndex == 4)
			return true;
		else
			return false;
	}
	
	private static function getLS():LevelSelector
	{
		if (sing == null)
			sing = new LevelSelector();
			
		return sing;
	}
	
	public static var singleton(getLS, null):LevelSelector;
	
	private function setCurrentLevelIndex(value:Int):Int
	{
		curLevelIndex = value;
		
		return value;
	}
	
	public var currentLevelIndex(null, setCurrentLevelIndex):Int;
}