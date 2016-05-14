package com.seiee.bullet.object
{
	import com.seiee.bullet.data.BulletData;
	import com.seiee.bullet.data.BulletPosition;
	
	import flash.display.Sprite;
	
	/**
	 * <b>BulletLane Class</b>
	 * <br>The class is a sprite of a single line for bullet showing.
	 * 
	 * <br>Author: Kevin Han
	 * <br>Updated on: 2014/10/18
	 * <br>Created on: 2014/10/9
	 */
	public class BulletLane extends Sprite implements IDisplayObject
	{
		/**
		 * Whether the lane is in the screen. 
		 */		
		public var hidden:Boolean;
		
		/**
		 * The list of bullets in the lane. 
		 */		
		protected var _bulletList:Vector.<Bullet>;
		
		/**
		 * The index of the lane. Using it to set positions.
		 */		
		protected var index:int;
		
		/**
		 * Position of the lane. It must be the values set in the class BulletPosition.
		 */
		protected var position:int;
		
		/**
		 * The initializing function of the class BulletLane. 
		 * @param index The index of the lane, starting from 0.
		 * @param position The position of the lane.
		 */
		public function BulletLane(index:int = 0, position:int = BulletPosition.DEFAULT)
		{
			super();
			this._bulletList = new Vector.<Bullet>();
			this.index = index;
			this.position = position;
			this.y = Global.config.LANE_TOP_OFFSET + index * laneHeight;
			this.hidden = false;
		}
		
		/**
		 * Getting whether a next bullet can show on the lane.
		 */
		public function canShowNext():Boolean
		{
			if (hidden || bulletList.length == 0)
				return true;
			return (bulletList[bulletList.length-1] as Bullet).canShowNext();
		}
		
		/**
		 * Push a bullet into the lane. 
		 * @param bulletData The data object of the bullet.
		 * 
		 */		
		public function pushBullet(bulletData:BulletData):void
		{
			if (hidden || !canShowNext() || bulletData == null)
				return;
			
			var bullet:Bullet = new Bullet(bulletData);
			bulletList.push(bullet);
			addChild(bullet);
		}
		
		/**
		 * @inheritDoc
		 */	
		public function update(currentTime:Date):void
		{
			for (var i:int = 0; i < bulletList.length; i++)
			{
				var bullet:Bullet = bulletList[i] as Bullet;
				bullet.update(currentTime);
				if (bullet.isComplete())
				{
					bullet.dispose();
					removeChild(bullet);
					bulletList.splice(i, 1);
					i--;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			for each (var bullet:Bullet in bulletList)
			{
				bullet.dispose();
				removeChild(bullet);
			}
			_bulletList = null;
		}
		
		/**
		 * The list of bullets in the lane. 
		 */		
		public function get bulletList():Vector.<Bullet>
		{
			return _bulletList;
		}
		
		/**
		 * Height of a lane.
		 */
		public static function get laneHeight():Number
		{
			return Global.config.LANE_HEIGHT;
		}
		
		/**
		 * The weight of the lane. A lane of lower weight has a higher priority of showing new bullets. 
		 * The formula of weight is: W = sum_of_bullets_weight + index
		 * (If inavailable to show a next bullet, W will be 999).
		 */		
		public function get showWeight():int
		{
			const MAX_WEIGHT:int = Global.config.MAX_WEIGHT;
			const INDEX_WEIGHT:int = Global.config.INDEX_WEIGHT;
			
			if (!canShowNext())
				return MAX_WEIGHT;
			
			var weight:Number = 0;
			for (var i:int = 0; i < bulletList.length; i++)
			{
				var bullet:Bullet = bulletList[i] as Bullet;
				weight += bullet.showWeight;	
			}
			weight += index * INDEX_WEIGHT;
			
			return weight;
		}
	}
}