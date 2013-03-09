﻿package game {	import flash.events.Event;	import game.objects.GameObject;	/**	 * Event related to the game.	 */	public class GameEvent extends Event {				/**		 *		 * Dispatched when the game (map) is loaded and ready to be initialized		 *		 */		public static const SPAWN_OBJECT:String   = "spawnObject";		public static const ENEMY_DIED:String	  = "enemyDied";		public static const PLAYER_DIED:String    = "playerDied";		public static const PLAYER_HIT:String     = "playerHit";		public static const FEAR_STATE:String     = "frighten";		public static const CHASE_STATE:String    = "chase";		public static const SCATTER_STATE:String  = "scatter";		public static const GAME_STARTED:String   = "gameStarted";		public static const GAME_LOADED:String    = "gameLoaded";		public static const GAME_PAUSED:String	  = "gamePaused";				public var damage_amount:int = 0;		public var current_target:GameObject;		public function GameEvent(type:String, damage_amount:int=0, current_target:GameObject=null, bubbles:Boolean=false, cancelable:Boolean=false) {			// constructor code			this.damage_amount = damage_amount;			this.current_target = current_target;			super(type,bubbles,cancelable);		}				public override function clone():Event {			return new  GameEvent(type, damage_amount,current_target, bubbles, cancelable);		}		public override function toString():String {			return formatToString("GameEvent","type","damage_amount", "current_target","bubble","cancelable");		}			}	}