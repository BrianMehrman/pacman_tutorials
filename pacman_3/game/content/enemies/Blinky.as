﻿package game.content.enemies {	import game.objects.Enemy;	import game.objects.MovementHandler;	import game.objects.GameObject;		public class Blinky extends Enemy {		public function Blinky(xTile:uint, yTile:uint, dirX:int, dirY:int, delay:int, clientHero:Boolean, initTarget:GameObject, movementHandler:MovementHandler):void {			super(24, 24, xTile, yTile, dirX, dirY, 5, 10, 2, delay, clientHero, initTarget, movementHandler);		}			}	}