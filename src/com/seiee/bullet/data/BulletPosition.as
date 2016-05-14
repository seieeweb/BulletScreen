package com.seiee.bullet.data
{
	/**
	 * <b>BulletPosition Class</b>
	 * <br>The class is an enumeration class for bullet positions.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/21
	 * <br>Created on: 2014/10/8
	 */
	public final class BulletPosition
	{
		/**
		 * Default position. Bullets moving from right to left.
		 */
		public static const DEFAULT:int = 0;
		/**
		 * Top position. Bullets showing on the top of the screen.
		 */
		public static const TOP:int = 1;
		/**
		 * Bottom position. Bullets showing on the bottom of the screen.
		 */
		public static const BOTTOM:int = 2;
		/**
		 * Manual position. The position is controlled by admin.
		 */
		public static const MANUAL:int = 3;
		
		/**
		 * The initializing function is invalid.
		 * It will throw an exception to avoid the initializing process.
		 */
		public function BulletPosition()
		{
			throw new Error("The BulletPosition class can't be instanced!");
		}
	}
}