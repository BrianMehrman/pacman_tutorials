﻿package game.controls {	import game.objects.GameObject;	import flash.events.Event;	import flash.utils.getQualifiedClassName;	import flash.utils.getQualifiedSuperclassName;	import game.objects.TargetTileMovement;	import game.objects.MovementEvent;	import game.objects.MovementHandler;	import game.ai.pathfinding.MapNode;	import game.ai.pathfinding.IPathfinder;	import game.GameEvent;		public class AIController {		public static const STATE_FEAR		= "frighten";		public static const STATE_SCATTER	= "scatter";		public static const STATE_CHASE		= "chase";				protected var _currentState:String;		protected var _gameObject:GameObject;		protected var _pathfinder:IPathfinder;		protected var _movementHandler:MovementHandler;						public function AIController(gameObject:GameObject, movementHandler:MovementHandler, pathfinder:IPathfinder):void {			// constructor code			this._gameObject = gameObject;			this._currentState = "";			this._movementHandler = movementHandler;			this._pathfinder = pathfinder;			// add		}				public function startListening():void {			this._gameObject.addEventListener(Event.ENTER_FRAME, checkLoop);		}				/*		 * Check Loop		 *		 * Check to see if the state should change or the target should change		 *		 */		protected function checkLoop(e:Event):void {			// check to see what state I should be in			var state:String = this._movementHandler.game.currentState;			var canChangeDirection:Boolean = this._gameObject.canChangeDirection();			checkHitTarget();			if(state != this._currentState || canChangeDirection){				this._currentState = state;				this._gameObject[state]();			}				// check to see if i am in an intersection		}				/*		 * Target Change		 *		 * Controls which tile to target next and changes the ai to that target.		 * 		 * Using the current target this function will determine which tile the target is one, then using its current		 * state target pattern (this should be a function) find the tile it should be targeting. Set AI controller's		 * 'newTarget' to that tile.		 * 		 */		protected function targetChange():void{			// get current target					}				/*		 *  State Change		 *		 *  Controls which state the enemy will change to when a state change is called		 *		 *  The state change is triggered by a time that will dispatch the stage change event. The function then		 *  looks at the current state and the hero's state to determine which state the enemy should be in. Current		 *  state available should be chase, frightened, scatter. 		 */		protected function stateChange():void {					}				/**		 *		 * hitTarget		 *		 * Check to see if this object has hit it's target.		 *		 **/		protected function checkHitTarget():void {			if(this._gameObject.hitTestObject(this._gameObject.targetObject)) {				trace("hit");				this._gameObject.stage.dispatchEvent(new GameEvent(GameEvent.PLAYER_HIT, 1, this._gameObject.targetObject));			}		}				/**		 * 		 * Checks if the clientHero is past the half-way point in his tile movement.  If so, we need to move an		 * extra tile on top of one we're already moving.		 * 		 * @return A <code>Vector.<uint></code> containing the x and y tiles to move to.  The first element is the		 * x tile, the second is the y.		 * 		 */				protected function checkExtraTiles():Vector.<uint> {			var returnTiles:Vector.<uint> = new Vector.<uint>();						returnTiles[0] =				(					(this._gameObject.moveDirX > 0 && this._gameObject.x%this._movementHandler.game.tileW > this._movementHandler.game.tileW/2) ||					(this._gameObject.moveDirX < 0 && this._gameObject.x%this._movementHandler.game.tileW < this._movementHandler.game.tileW/2)				) ?				this._gameObject.xTile + this._gameObject.moveDirX :				this._gameObject.xTile;						returnTiles[1] =				(					(this._gameObject.moveDirY > 0 && this._gameObject.y%this._movementHandler.game.tileH > this._movementHandler.game.tileH/2) ||					(this._gameObject.moveDirY < 0 && this._gameObject.y%this._movementHandler.game.tileH < this._movementHandler.game.tileH/2)				) ?				this._gameObject.yTile + this._gameObject.moveDirY :				this._gameObject.yTile;						return returnTiles;		}				public function newTarget(destX:Number, destY:Number):void {			this._gameObject.targetTileX = destX;			this._gameObject.targetTileY = destY;						if(!this._movementHandler.game.gameTiles[destX][destY].solid && (this._gameObject.xTile != destX || this._gameObject.yTile != destY)) {								var path:Vector.<MapNode>;								if(this._gameObject.targetTileMovement == null) {					path = this._pathfinder.findPath(this._gameObject.xTile, this._gameObject.yTile, destX, destY, this._movementHandler.game.gameTiles);					path = this._pathfinder.getCorners(path);					this._gameObject.currentPath = path;										this.followPath();				} else {										var tiles:Vector.<uint> = this.checkExtraTiles();										path = this._pathfinder.findPath(tiles[0], tiles[1], destX, destY, this._movementHandler.game.gameTiles);					path = this._pathfinder.getCorners(path);										this._gameObject.currentPath = path;										this._gameObject.targetTileMovement = new TargetTileMovement(tiles[0], tiles[1], this._gameObject.dirX, this._gameObject.dirY);				}				this._movementHandler.addEventListener(MovementEvent.TILE_MOVEMENT_OVER, this.followPath);			}		}				protected function followPath(event:MovementEvent = null):void {			if(this._gameObject.currentPath && this._gameObject.currentPath.length != 0) {				var nextNode:MapNode = this._gameObject.currentPath.shift();								var dirX:int = 0;				var dirY:int = 0;								if(nextNode.xCoord < this._gameObject.xTile) {					dirX = -1;				} else if(nextNode.xCoord > this._gameObject.xTile) {					dirX = 1;				}								if(nextNode.yCoord < this._gameObject.yTile) {					dirY = -1;				} else if(nextNode.yCoord > this._gameObject.yTile) {					dirY = 1;				}								this._gameObject.targetTileMovement = new TargetTileMovement(nextNode.xCoord, nextNode.yCoord, dirX, dirY);								this._movementHandler.finishTileMovement(this._gameObject);			} else {				this._gameObject.targetTileMovement = null;				this._gameObject.stopCurAnim();			}		}	}	}