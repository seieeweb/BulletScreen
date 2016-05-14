package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.data.BulletPosition;
	
	/**
	 * <b>FixedBulletLane Class</b>
	 * <br>The class is a sprite of a single line for fixed bullet showing.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/16
	 * <br>Created on: 2014/10/15
	 */
	public class FixedBulletLane extends BulletLane
	{
		/**
		 * A const indicating the lane is on the top. 
		 */		
		public static const TOP_LANE:int = 1;
		/**
		 * A const indicating the lane is on the bottom. 
		 */	
		public static const BOTTOM_LANE:int = 2;
		
		/**
		 * The initializing function of the class FixedBulletLane. 
		 * @param index The index of the lane, starting from 0.
		 * @param position The position of the lane. It cannot be 0 because this is a lane of fixed bullets.
		 */	
		public function FixedBulletLane(index:int = 0, position:int = 0)
		{
			super(index, position);
			if (position == BulletPosition.DEFAULT)
			{
				throw new Error("Not a fixed lane!");
				return;
			}
		}
			
		override public function pushBullet(bulletData:BulletData):void
		{
			if (hidden || !canShowNext() || bulletData == null)
				return;
			
			var bullet:FixedBullet = new FixedBullet(bulletData);
			bulletList.push(bullet);
			addChild(bullet);
		}
		
		/**
		 * Update the position of the bullets accordint to stageWidth. 
		 * 
		 */	
		public function updatePosition():void
		{
			for each(var bullet:FixedBullet in bulletList)
			{
				bullet.updatePosition();
			}
		}
		
		override public function get showWeight():int
		{
			const MAX_WEIGHT:int = Global.config.MAX_WEIGHT;
			const INDEX_WEIGHT:int = Global.config.INDEX_WEIGHT;
			
			if (!canShowNext())
				return MAX_WEIGHT;
			
			var weight:Number = 0;
			weight += ((position == BulletPosition.TOP) ? index : (Global.scene.bottomLaneCount - index - 1)) 
				      * INDEX_WEIGHT;
			
			return weight;
		}
	}
}