package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	
	/**
	 * <b>ManualBullet Class</b>
	 * <br>The class is a sprite showing a bullet controlled manually.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/21
	 * <br>Created on: 2014/10/21
	 */
	public class ManualBullet extends FixedBullet
	{
		/**
		 * The initializing function. 
		 * @param data BulletData
		 * 
		 */		
		public function ManualBullet(data:BulletData)
		{
			super(data);
		}
		
		override public function canShowNext():Boolean
		{
			return false;
		}
		
		override protected function getShowTime(textWidth:Number):Number
		{
			return 0;
		}
		
		override protected function get fontSize():Number
		{
			return Global.config.MANUAL_FONT_SIZE;
		}
		
		override public function get showWeight():int
		{
			return Global.config.MAX_WEIGHT;
		}
	}
}