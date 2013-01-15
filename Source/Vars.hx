package ;
import nme.Assets;

class Vars 
{
	
	private static function getHeadingFontSize():Int {
		#if halfsize
		return 48;
		#else
		return 96;
		#end
	}
	public static var headingFontSize(getHeadingFontSize, null):Int;
	
	private static function getNormalFontSize():Int {
		#if halfsize
		return 16;
		#else
		return 32;
		#end
	}
	public static var normalFontSize(getNormalFontSize, null):Int;
	
	private static function getSmallestFontSize():Int {
		#if halfsize
		return 8;
		#else
		return 16;
		#end
	}
	public static var smallestFontSize(getSmallestFontSize, null):Int;
	
	private static function getFlixelWidth():Int {
		#if halfsize
		return 640;
		#else
		return 1280;
		#end
	}
	public static var flixelWindowWidth(getFlixelWidth, null):Int;
	
	private static function getFlixelHeight():Int {
		#if halfsize
		return 360;
		#else
		return 720;
		#end
	}
	public static var flixelWindowHeight(getFlixelHeight, null):Int;
	
	private static function getHalfsizeFix():Float {
		
		#if halfsize
		return 0.5;
		#else
		return 1;
		#end
	}
	public static var halfsizeFix(getHalfsizeFix, null):Float;
	
	private static function getFont_Visitor():String {
		return Assets.getFont("fonts/visitor2.ttf").fontName;
	}
	
	public static var fontVisitor(getFont_Visitor, null):String;
	
	private static function getFont_Paskowy():String {
		return Assets.getFont("fonts/Paskowy.ttf").fontName;
	}
	
	public static var fontPaskowy(getFont_Paskowy, null):String;
	
}