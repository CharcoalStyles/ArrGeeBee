package ;
import nme.Lib;
import org.flixel.FlxGame;
import org.flixel.FlxG;
import com.charcoalStyles.rgb.Menu;

/**
 * ...
 * @author Aaron
 */

class Game extends FlxGame
{

	#if flash
	public static var SoundExtension:String = ".mp3";
	#else
	public static var SoundExtension:String = ".wav";
	#end
	
	public static var SoundOn:Bool = true;
	
	public function new()
	{
		var scale:Int = 1;
		var stageWidth:Int = Std.int(Vars.flixelWindowWidth / scale);
		var stageHeight:Int = Std.int(Vars.flixelWindowHeight / scale);
		forceDebugger = true;
		
		super(stageWidth, stageHeight, Menu, scale, 60, 30);
		
		#if mobile
		FlxG.mobile = true;
		#else
		FlxG.mobile = false;
		#end
	}
}