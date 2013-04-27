package game{	import game.ai.pathfinding.AStar;	import game.ai.pathfinding.IPathfinder;	import game.controls.Controls;	import game.controls.InputHandler;	import game.map.MapDataEvent;	import game.map.MapHandler;	import game.objects.Hero;	import game.objects.HeroHandler;	import game.objects.MovementHandler;	import game.content.heroes.Pacman;	import flash.display.MovieClip;	import flash.events.Event;	import flashx.textLayout.elements.Configuration;	import game.objects.MovementEvent;	import game.objects.EnemyHandler;	import game.objects.Enemy;	import game.map.TileEvent;	import flash.utils.Timer;	import flash.events.TimerEvent;	import game.objects.GameObjectEvent;	import game.objects.GameObject;	import game.objects.Pellet;	import game.map.ScoreBoard;	public class GameClient extends MovieClip	{		protected var _mapHandler:MapHandler;		protected var _heroHandler:HeroHandler;		protected var _enemyHandler:EnemyHandler;		protected var _movementHandler:MovementHandler;		protected var _inputHandler:InputHandler;		protected var _pathFinder:IPathfinder;		protected var _controls:Controls;		protected var _spawnList:Array;		protected var _game:Game;		protected var _scoreboard:ScoreBoard;		/**		 * 		 * Constructor for a new game client.		 * 		 * @param tilesetsURL The url to the tilesets JSON.		 * @param mapsURL The url to the maps JSON.		 * @param tileW The tile width in pixels.		 * @param tileH The tile height in pixels.		 * @param gravity The pixels per frame that is subtracted from the object's velocity when jumping.		 * @param tiltRatio The tiltRatio of the shadows.		 * @param strafing <code>true</code> if strafing is enabled, <code>false</code> if not.		 * @param movementType The movement type, from public static constants on the <code>Game</code> object.		 * 		 */		public function GameClient(tilesetsURL:String, mapsURL:String, tileW:int, tileH:int, gravity:Number=1, tiltRatio:Number=1, strafing:Boolean=false, movementType:String=Game.NORMAL):void		{			// init map handler			var tilesContainer:MovieClip = new MovieClip();			this._mapHandler = new MapHandler();			this._mapHandler.load(tilesetsURL, mapsURL);			this._mapHandler.addEventListener(MapDataEvent.MAPS_LOADED, this.gameReady);			this._spawnList = new Array();			this._scoreboard = new ScoreBoard();			this.addChild(tilesContainer);			this.addChild(this._scoreboard);			this._game = new Game(tilesContainer,tileW,tileH,gravity,tiltRatio,strafing,movementType);		}		protected function gameReady(event:MapDataEvent):void		{			this.initGame();			this.stage.dispatchEvent(new GameEvent(GameEvent.GAME_LOADED));		}		public function initGame():void		{			this._movementHandler = new MovementHandler(this._game);			this._inputHandler = new InputHandler(this.stage);			this._heroHandler = new HeroHandler(this._game.tilesContainer);			this._enemyHandler = new EnemyHandler(this._game.tilesContainer);			this._pathFinder = new AStar();			this.setState(GameEvent.CHASE_STATE);			this._controls = new Controls(this._game,this._movementHandler,this._inputHandler,this._pathFinder);			this._controls.startListening();						//this.stage.addEventListener(GameEvent.PLAYER_DIED, heroDied);			this.stage.addEventListener(GameEvent.PLAYER_HIT, hitPlayer);			this.stage.addEventListener(TileEvent.SPAWN_OBJECT, spawnTileObjects);			this.stage.addEventListener(GameObjectEvent.OBJECT_COLLECTED, objectCollected);		}		public function spawnTileObjects(e:TileEvent):void		{			e.spawn_tile.spawn(1,this);			this._spawnList.push(e.spawn_tile);		}		/*		 * Hit Player		 * 		 * This handles any attack against the player		 */		public function hitPlayer(event:GameEvent):void		{			// determine the amount of damage in the attack						// can target be hit			if (event.current_target.is_vulnerable)			{				event.current_target.damage(event.damage_amount);			}		}		/*		 * Hero Died		 * 		 * This handles reseting the level and reseting the game.		 */		public function heroDied(e:Event):void		{			// remove the controls			this._controls.stopListening();			if (this._game.clientHero.lives <= 0)			{				// game over, go to score screen				this.endGame();			}			else			{				// restart level				this._game.clientHero.lives -=  1;				// Create 'pause screen', display 'Press any key to start'				var t:Timer = new Timer(5);				t.addEventListener(TimerEvent.TIMER, restartLevel);				t.start();			}		}				public function objectCollected(e:GameObjectEvent):void {			var obj:GameObject = e.collector;			var item:Pellet = e.item as Pellet;			// apply collected object.			item.pickedUp(obj);			// remove item from game board.			if(item.parent != null){				item.parent.removeChild(item);				this._game.gameObjects.splice(this._game.gameObjects.indexOf(item),1);			}		}				/*		 * Enemy Died		 * This handles removing the enemy and adding points to the score		 */		public function endGame():void		{						// show game over screen		}		public function restartLevel(e:TimerEvent):void		{			e.currentTarget.removeEventListener(TimerEvent.TIMER, restartLevel);			e.currentTarget.stop();			// remove enimies			this._enemyHandler.removeEnemies();			// remove hero, if hero is there			//this._heroHandler.removeHeroes();			// remove fruit			// add hero			this.respawnHero();			// add enemy			this.stage.dispatchEvent(new GameEvent(GameEvent.GAME_RESTARTED));//			for(var i:int=0;i<this._spawnList.length;i++) {		//		this._spawnList[i].spawn(1,this);			//}			// fire off game start		}		public function respawnHero():void 		{			var hero:Hero = this._game.clientHero;			this._heroHandler.addHero(hero);			hero.respawn();			hero.addEventListener(Event.REMOVED_FROM_STAGE, this.heroDied);			this._movementHandler.teleportObject(hero, hero.spawnX, hero.spawnY);			this._controls.startListening();		}		public function setState(newState:String):void		{			this._game.currentState = newState;			this.dispatchEvent(new GameEvent(newState));		}		protected function destroyGame():void		{			this._game.tilesContainer = new MovieClip();			this._movementHandler = null;			this._inputHandler = null;			this._heroHandler = null;			this._enemyHandler = null;			this._pathFinder = null;			this._controls = null;		}		public function addHero(HeroClass:Class, xTile:int, yTile:int, dirX:int, dirY:int, clientHero:Boolean):void		{						if (this._heroHandler != null)			{				var hero:Hero = new HeroClass(xTile,yTile,dirX,dirY,clientHero,this._game);				this._heroHandler.addHero(hero);				this._game.addGameObject(hero);				if (clientHero)				{					this._game.clientHero = hero;					this._scoreboard.init(hero);				}				hero.addEventListener(Event.REMOVED_FROM_STAGE, this.heroDied);				this._movementHandler.teleportObject(hero, hero.xTile, hero.yTile);			}		}		public function addEnemy(EnemyClass:Class, delay:int, xTile:int, yTile:int, dirX:int, dirY:int, clientHero:Boolean):void		{			if (this._enemyHandler != null)			{				var enemy:Enemy = new EnemyClass(xTile,yTile,dirX,dirY,delay,clientHero,this._game.clientHero,this._movementHandler);				this._enemyHandler.addEnemy(enemy);				this._game.addGameObject(enemy);				this._movementHandler.teleportObject(enemy, enemy.xTile, enemy.yTile);				this.stage.focus = this.stage;			}		}				public function addGameObject(object:GameObject):void {							 this._movementHandler.teleportObject(object, object.xTile, object.yTile);			 this._game.gameObjects.push(object);			 this._game.tilesContainer.addChild(object);		 }		public function loadMap(mapID:int):void		{			this._game.buildMap(this._mapHandler.getMap(mapID));		}				public function unLoadMap():void {			// remove all tiles and that which the tiles created		}				public function showPauseScreen(e:GameEvent):void 		{			// disable controls						// pause AI						// pause any other timers						// display Pause overlay						// add ui controls						// add key bindings						// enable controls when exit		}				public function showGameOverScreen(e:GameEvent):void		{			// disable controls						// stop all timers						// stop all events						// stop all ai						// add ui controls						// add key bindings		}	}}