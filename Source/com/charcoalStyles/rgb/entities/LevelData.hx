package com.charcoalStyles.rgb.entities;
import com.skyhammer.entites.ShEntity;

/**
 * ...
 * @author Aaron
 */

class LevelData extends ShEntity
{
	private var _title:String;
	private var _subTitle:String;
	
	private var _isAllMove:Bool;

	public function new() 
	{
		super();
		_title = "";
		_subTitle = "";
		_isAllMove = false;
	}
	
	private function setTitle(value:String):String
	{
		_title = value;
		
		return value;
	}
	private function getTitle():String
	{
		return _title;
	}
	public var title(getTitle, setTitle):String;
	
	private function setSubTitle(value:String):String
	{
		_subTitle = value;
		
		return value;
	}
	private function getSubTitle():String
	{
		return _subTitle;
	}
	public var subTitle(getSubTitle, setSubTitle):String;
	
	private function setIsAllMove(value:Bool):Bool
	{
		isAllMove = value;
		
		return value;
	}
	private function getIsAllMove():Bool
	{
		return isAllMove;
	}
	public var isAllMove(getIsAllMove, setIsAllMove):Bool;
}