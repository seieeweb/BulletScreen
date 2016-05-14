package com.seiee.bullet.data
{
	/**
	 * <b>BulletData Class</b>
	 * <br>The class is a wrapper for some attributes of a bullet.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/8
	 * <br>Created on: 2014/10/8
	 */
	public class BulletData
	{
		
		/**
		 * Posted time of the bullet.
		 */
		public var postTime:Date;
		
		/**
		 * Author of the bullet.
		 */
		public var author:String;
		
		/**
		 * Text of the bullet.
		 */
		public var text:String;
		
		/**
		 * Position of the bullet. It must be the values set in the class BulletPosition.
		 */
		public var position:int;
		
		/**
		 * Color of the bullet. Using RGB color.
		 */
		public var color:uint;
		/**
		 * The index of the lane. Set for special bullets. For default bullets, set this value as -1.
		 */		
		public var laneIndex:int;
		
		/**
		 * Initializing function.
		 * @param postTime Posted Time
		 * @param text Text
		 * @param author Author
		 * @param position Position
		 * @param color Color
		 * 
		 */		
		public function BulletData(postTime:Date, text:String, author:String = null, position:int = 0, color:uint = 0xffffff, laneIndex:int = -1)
		{
			this.postTime = postTime;
			this.text = text;
			this.author = author;
			this.position = position;
			this.color = color;
			this.laneIndex = laneIndex;
		}
		
		/**
		 * Getting a copy of the data. 
		 * @return a copyed object.
		 * 
		 */		
		public function clone():BulletData
		{
			return new BulletData(postTime, text, author, position, color, laneIndex);
		}
	}
}