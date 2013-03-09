﻿package game.objects {		import flash.display.FrameLabel;	import flash.display.MovieClip;	import flash.display.Shape;	import flash.events.Event;	import game.ai.pathfinding.MapNode;	import game.Game;	import game.GameEvent;		public class GameObject extends MovieClip {		public var xTile:int;		public var yTile:int;		public var objectWidth:uint;		public var objectHeight:uint;		public var halfWidth:uint;		public var halfHeight:uint;		public var dirX:int;		public var dirY:int;		public var moveDirX;		public var moveDirY;		public var speed:int;		public var jumpState:JumpState;		public var health:int;		public var targetTileMovement:TargetTileMovement = null;		public var clientHero:Boolean;		public var currentPath:Vector.<MapNode>;		public var is_vulnerable:Boolean;		public var score:int = 0;		public var spawnX:int;		public var spawnY:int;				public var xOnPlane;		public var yOnPlane;		public var lives:int = 0; // only a hero will have lives		public var targetObject:GameObject;		public var targetTileX:int;		public var targetTileY:int;		public var canMove:Boolean;		protected var _requiredLabels:Array = new Array();		protected var _game:Game;		protected var _lengths:Object = new Object();				protected var _currentAnimLabel:String;		public var shadow:Shape = new Shape();				/**		 *		 * @param objectWidth The registered width of the object.		 * @param objectHeight The registered height of the object.		 * @param xTile The starting x tile coordinate of the object.		 * @param yTile The starting y tile coordinate of the object.		 * @param dirX The starting x direction of the object.  -1 means left, 1 right, 0 up or down.		 * @param dirY The starting y direction of the object.  -1 means up, 1 down, 0 left or right.		 * @param speed The speed of the object in pixels per frame.		 * @param requiredLabels The required frame labels.		 *		 */		public function GameObject(objectWidth:uint, objectHeight:uint, xTile:uint, yTile:uint, dirX:int, dirY:int, speed:int, requiredLabels:Array, game:Game):void {			this.objectWidth = objectWidth;			this.objectHeight = objectHeight;						this.halfWidth = objectWidth/2;			this.halfHeight = objectHeight/2;						this.xTile = xTile;			this.yTile = yTile;			this.dirX = dirX;			this.dirY = dirY;			this.spawnX = xTile;			this.spawnY = yTile;			this.health = 1;			this.speed = speed;			this._requiredLabels = requiredLabels;			this._game = game;						this.checkLabels();			this.setLengths();			// Add main check loop			this.addEventListener(Event.ENTER_FRAME, this.checkLoop);			this.addShadow();			this.addChild(this.shadow);			this.setChildIndex(this.shadow, 0);			//this.canMove = true;			this.move(dirX, dirY, dirX, dirY);			this.stopCurAnim();		}				protected function addShadow():void{			this.shadow.graphics.beginFill(0x000000);			this.shadow.graphics.drawCircle(0, 0, 10);			this.shadow.graphics.endFill();		}		/**		 * 		 * Gets a frame number from a frame label.		 * 		 * @param label The label.		 * 		 */				protected function getFrameNumber(label:String):int {			// Loop through current labels			for each(var frameLabel:FrameLabel in this.currentLabels) {				// If this is our label...				if(frameLabel.name == label) {					// Return the frame number					return frameLabel.frame;				}			}			// If nothing was found, return an impossible frame number			return -1;		}				/*		 * Play game objects death animation		 */				public function playDeath():void {			this.canMove = false;			this._currentAnimLabel = "_death";			this.gotoAndPlay(this.getFrameNumber("_death"));			// add listener to remove game object when death animation is done			}				public function respawn():void {			this.canMove = true;			this.is_vulnerable = true;			this.health=1;			// need to get hero spawn info from somewhere?			this.xTile = 1;			this.yTile = 1;			this.dirX = 0;			this.dirY = 0;						this.addEventListener(Event.ENTER_FRAME, this.checkLoop);			this.move(dirX, dirY, dirX, dirY);			this.stopCurAnim();		}		/*		 * Apply damage to game objects		 *		 */				public function damage(damage_amount:int):void {			trace("applying damage");			if ((this.health - damage_amount) <= 0) {				this.health = 0;				trace("died");				// stop ability to move				this.stopCurAnim();				// object is not vulnurable when playing death animation				this.is_vulnerable = false;								// play death animation								this.playDeath();								// fire off player died event ( eventually we will be adding the reference to the game object that died)				if (this.clientHero) {					this.stage.dispatchEvent(new GameEvent(GameEvent.PLAYER_DIED) );				} else {					this.stage.dispatchEvent(new GameEvent(GameEvent.ENEMY_DIED) );				}							} else {				this.health-=damage_amount;			}		}						/**		 * 		 * Checks if all the labels are present.		 * 		 */				protected function checkLabels():void {			for each(var label:String in this._requiredLabels) {				if(this.getFrameNumber(label) == -1) {					throw new Error("Missing Required Animation Label: "+label);				}			}		}				public function canChangeDirection():Boolean {			var direction_options:int = 0;			var dirs:Array = [[0,-1],[0,1],[0,1],[-1,0]];							if (this.targetObject != null && (this.targetTileX != this.targetObject.xTile ||this.targetTileY != this.targetObject.yTile) ) {				return true;			}			return false;		}				public function chase():void {			// default chase bahavior. 						// find targets tile in front or behind them		}				public function scatter():void {			// find the furthest point from the target 						// go through teleport if close					}				public function frighten():void {			// run away from target					}				/**		 * 		 * Sets the lengths of each animation.		 * 		 */		protected function setLengths():void {			// Loop through each of this.currentLabels			for(var key:String in this.currentLabels) {				// If there is another label past the current one..				if(this.currentLabels[String(Number(key) + 1)]) {					// The length of the current label is set to the frame of the next label minus the frame of the current label minus 1 (for the keyframe)					this._lengths[this.currentLabels[key].name] = this.currentLabels[String(Number(key) + 1)].frame - this.currentLabels[key].frame - 1;				} else {					// Otherwise, there is no further labels and the end of the MovieClip is used instead of the next label					this._lengths[this.currentLabels[key].name] = this.totalFrames - this.currentLabels[key].frame;				}			}		}				/**		 * 		 * Checks if we're at the end of the current animation.  If we are, it restarts it.		 * 		 */				protected function checkLoop(event:Event):void {			var labelFrame:int = this.getFrameNumber(this._currentAnimLabel);			if(this.currentFrame == labelFrame + this._lengths[this._currentAnimLabel]) {				if (this._currentAnimLabel == "_death"){					if (this.parent.getChildIndex(this)){						this.parent.removeChild(this);						this.destroy();					}				}				this.gotoAndPlay(labelFrame);			}		}				public function destroy():void {						this.removeEventListener(Event.ENTER_FRAME, checkLoop);		}				/**		 *		 * Stops the current animation.		 *		 */				public function stopCurAnim():void {			this.gotoAndStop(this.getFrameNumber(this._currentAnimLabel));			this.moveDirX = 0;			this.moveDirY = 0;		}									/**		 *		 * Gets the animation label.  Meant to be overridden.		 *		 * @param moveDirX The direction the object is moving on the x plane.		 * @param moveDirY The direction the object is moving on the y plane.		 * @param dirX The direction the object is facing on the x plane.		 * @param dirY The direction the object is facing on the y plane.		 * @param jump <code>true</code> if the move is a jump, <code>false</code> if it is not.		 *		 */				protected function getAnimLabel(moveDirX:int, moveDirY:int, dirX:int, dirY:int, jump:Boolean=false):String { return ""; }				/**		 *		 * Preps the character for moving.		 *		 * @param moveDirX The direction the character is moving on the x plane.		 * @param moveDirY The direction the character is moving on the y plane.		 * @param dirX The direction the character is facing on the x plane.		 * @param dirY The direction the character is facing on the y plane.		 * @param jumpState The jumpState of the object.		 *		 */				public function move(moveDirX:int, moveDirY:int, dirX:int, dirY:int, jumpState:JumpState = null):void {			if(this.canMove!=true) {				this.moveDirX = 0;				this.moveDirY = 0;				return;			}						if(this.jumpState != null && jumpState != null) {				this.moveDirX = moveDirX;				this.moveDirY = moveDirY;			} else if(moveDirX != this.moveDirX || moveDirY != this.moveDirY || dirX != this.dirX || dirY != this.dirY || jumpState != this.jumpState) {				var animLabel:String = this.getAnimLabel(moveDirX, moveDirY, dirX, dirY, (jumpState != null));				this._currentAnimLabel = animLabel;				this.gotoAndPlay(this.getFrameNumber(animLabel));				this.dirX = dirX;				this.dirY = dirY;				this.moveDirX = moveDirX;				this.moveDirY = moveDirY;						this.jumpState = jumpState;			}		}			}	}