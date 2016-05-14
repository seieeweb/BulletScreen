package com.seiee.bullet.data
{
	/**
	 * <b>BulletManager Class</b>
	 * <br>The class is a manager of bullet data.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/21
	 * <br>Created on: 2014/10/10
	 */
	public class BulletManager
	{
		/**
		 * BulletData Queue.
		 */		
		private var dataList:Vector.<BulletData>;
		/**
		 * Top BulletData Queue.
		 */		
		private var topDataList:Vector.<BulletData>;
		/**
		 * Bottom BulletData Queue.
		 */		
		private var bottomDataList:Vector.<BulletData>;
		/**
		 * The array of BulletData queues. 
		 */		
		private var listArray:Vector.<Vector.<BulletData>>;
		/**
		 * The last shifted data for roll back.
		 */		
		private var lastData:Vector.<BulletData>;
		
		/**
		 * The initialzing function. 
		 * 
		 */		
		public function BulletManager()
		{
			init();
		}
		
		/**
		 * Internal initialzing function. 
		 * 
		 */		
		private function init():void
		{
			dataList = new Vector.<BulletData>();
			topDataList = new Vector.<BulletData>();
			bottomDataList = new Vector.<BulletData>();
			listArray = Vector.<Vector.<BulletData>>([dataList, topDataList, bottomDataList]);
			lastData = Vector.<BulletData>([null, null, null]);
		}
		
		/**
		 * Pushing a new bullet into the waiting pool. 
		 * @param data The data of the bullet.
		 * 
		 */		
		public function push(data:BulletData):void
		{
			if (data == null)
				return;
			
			var pushData:BulletData = data.clone();
			pushData.color = Global.config.COLOR_LIST[int(Math.random() * Global.config.COLOR_LIST.length)];
			
			if (pushData.position == BulletPosition.MANUAL)
			{
				Global.manualController.updateData(pushData);
				return;
			}
			
			listArray[data.position].push(pushData);
		}
		
		/**
		 * Getting whether next bullet is available in the waiting pool. 
		 * 
		 */		
		public function hasNext(currentTime:Date, position:int = BulletPosition.DEFAULT):Boolean
		{
			if (listArray[position].length == 0)
				return false;
			
			if (listArray[position][0].postTime > currentTime)
				return false;
			
			return true;
		}
		
		/**
		 * Getting the next bullet data.
		 * @return a BulletData object.
		 * 
		 */		
		public function next(currentTime:Date, position:int = BulletPosition.DEFAULT):BulletData
		{
			const SHOWING_OFFSET_TIME:Number = Global.config.SHOWING_OFFSET_TIME;
			
			if (!hasNext(currentTime, position))
				return null;
			
			lastData[position] = listArray[position].shift() as BulletData;
			lastData[position].postTime = new Date(new Date().time + SHOWING_OFFSET_TIME);
			return lastData[position];
		}
		
		/**
		 * Undo the last next operation.
		 * Putting the last BulletData object back into the waiting pool. 
		 * 
		 */		
		public function undo(position:int = BulletPosition.DEFAULT):void
		{
			if (lastData[position] == null)
				return;
			
			listArray[position].unshift(lastData[position]);
			lastData[position] = null;
		}
	}
}