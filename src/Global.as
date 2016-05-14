package
{
	import com.seiee.bullet.controller.ManualBulletController;
	import com.seiee.bullet.data.BulletConfig;
	import com.seiee.bullet.data.BulletManager;
	import com.seiee.bullet.net.ServerConnection;
	import com.seiee.bullet.object.Bullet;
	import com.seiee.bullet.object.MessageBox;
	import com.seiee.bullet.scene.BulletScreen;
	
	import flash.display.Sprite;
	import flash.display.Stage;

	/**
	 * <b>Global Class</b>
	 * <br>The class is a wrapper for some variabled and functions.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2015/10/24
	 * <br>Created on: 2014/10/8
	 */
	public final class Global
	{
		
		// Program info
		public static const PRODUCT:String = "Bullet Screen Projector"
		public static const VERSION:String = "Version 1.1.7";
		public static const COPYRIGHT:String = "(C) 2014-2016 SEIEE Student Union";
		
		/**
		 * The scene of the screen. 
		 */		
		public static var scene:BulletScreen;
		/**
		 * The stage of the screen. 
		 */		
		public static var stage:Stage;
		
		/**
		 * The manager of BulletData objects. 
		 */		
		public static var bulletManager:BulletManager;
		/**
		 * The controller of manual lanes.
		 */		
		public static var manualController:ManualBulletController;
		/**
		 * The config object. 
		 */		
		public static var config:BulletConfig;
		/**
		 * The message object. 
		 */		
		public static var message:MessageBox;
		/**
		 * The server adapter. 
		 */		
		public static var server:ServerConnection;
		
		/**
		 * The initializing function is invalid.
		 * It will throw an exception to avoid the initializing process.
		 */
		public function Global()
		{
			throw new Error("The Global class can't be instanced!");
		}
	}
}