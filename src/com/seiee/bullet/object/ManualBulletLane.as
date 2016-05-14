package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.data.BulletPosition;
	
	/**
	 * <b>ManualBulletLane Class</b>
	 * <br>The class is a sprite of a single line for manual control.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/21
	 * <br>Created on: 2014/10/21
	 */
	public class ManualBulletLane extends BulletLane
	{	
		/**
		 * The initializing function of the class FixedBulletLane. 
		 * @param index The index of the lane, starting from 0.
		 * @param position The position of the lane. It cannot be 0 because this is a lane of fixed bullets.
		 */	
		public function ManualBulletLane(index:int = 0)
		{
			super(index, BulletPosition.MANUAL);
			updatePosition();
		}
		
		override public function pushBullet(bulletData:BulletData):void
		{
			if (hidden || !canShowNext() || bulletData == null)
				return;
			
			var bullet:ManualBullet = new ManualBullet(bulletData);
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
			
			this.y = Global.stage.stageHeight - manualLaneHeight * (index + 1);
		}
		
		override public function update(currentTime:Date):void
		{
			return;
		}
		
		/**
		 * Manually pop the current bullet out of the lane. 
		 * 
		 */		
		public function popBullet():void
		{
			if (bulletList.length == 0)
				return;
			
			var bullet:Bullet = bulletList.pop();
			bullet.dispose();
			removeChild(bullet);
		}
		
		public function getText():String
		{
			if (bulletList.length == 0)
				return null;
			
			return bulletList[0].data.text;
		}
		
		/**
		 * Height of a lane.
		 */
		public static function get manualLaneHeight():Number
		{
			return Global.config.MANUAL_LANE_HEIGHT;
		}
		
		override public function get showWeight():int
		{		
			if (!canShowNext())
				return Global.config.MAX_WEIGHT;
			
			return 0;
		}
	}
}