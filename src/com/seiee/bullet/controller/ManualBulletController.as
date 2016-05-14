package com.seiee.bullet.controller
{
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.object.ManualBulletLane;

	/**
	 * <b>ManualBulletController Class</b>
	 * <br>The class is the controller for manual action.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/22
	 * <br>Created on: 2014/10/21
	 */
	public class ManualBulletController
	{
		/**
		 * The list of manual lanes. 
		 */		
		private var laneList:Vector.<ManualBulletLane>;
		
		/**
		 * The initialzing function of the class. 
		 * @param laneList The laneList bound to the controller.
		 * 
		 */		
		public function ManualBulletController(laneList:Vector.<ManualBulletLane>)
		{
			this.laneList = laneList;
		}
		
		/**
		 * Pushing a new bullet into a given lane.
		 * @param index the index of the lane
		 * @param data the data of the bullet
		 * @return whether the pushing action is successfull
		 * 
		 */		
		public function pushBullet(index:uint, data:BulletData):Boolean
		{
			if (index >= laneList.length)
				return false;
			
			if (!laneList[index].canShowNext())
				return false;
			
			laneList[index].pushBullet(data);
			return true;
		}
		
		/**
		 * Popping a bullet from a lane. 
		 * @param index the index of the lane
		 * @return whether the popping action is successfull
		 * 
		 */		
		public function popBullet(index:uint):Boolean
		{
			if (index >= laneList.length)
				return false;
			
			if (laneList[index].showWeight == 0)
				return false;
			
			laneList[index].popBullet();
			return true;
		}
		
		/**
		 * Update the position of lanes. 
		 * 
		 */		
		public function updatePosition():void
		{
			for (var i:int = 0; i < laneList.length; i++)
			{
				var lane:ManualBulletLane = laneList[i] as ManualBulletLane;
				lane.updatePosition();
			}
		}
		
		/**
		 * Update the status with the manual status from server. 
		 * @param data The data from server.
		 * 
		 */		
		public function updateData(data:BulletData):void
		{
			if (data.text == laneList[data.laneIndex].getText())
				return;
			
			popBullet(data.laneIndex);
			if (data.text == "")
				return;
			
			pushBullet(data.laneIndex, data);
		}
	}
}