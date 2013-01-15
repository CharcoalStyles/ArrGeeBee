package com.charcoalStyles.rgb.entities;
import com.skyhammer.entites.ShEntity;

/**
 * ...
 * @author Aaron
 */

class PlayerSpawn extends ShEntity
{
	private var numBlobs:Int;

	public function new() 
	{
		super();
	}
	
	private function setNumberOfBlobs(value:Int):Int
	{
		numBlobs = value;
		
		return value;
	}
	private function getNumberOfBlobs():Int
	{
		return numBlobs;
	}
	
	public var numberOfBlobs(getNumberOfBlobs, setNumberOfBlobs):Int;
}