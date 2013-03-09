﻿package game.map {		import game.map.Map;		import flash.events.Event;	import flash.events.EventDispatcher;	import flash.net.URLLoader;	import flash.net.URLRequest;	import game.map.MapDataEvent;	import com.adobe.serialization.json.JSON;		/**	 *	 * Manages maps	 *	 */	 	public class MapHandler extends EventDispatcher {		protected var _urlLoader:URLLoader = new URLLoader();		protected var _maps:Array = new Array();		protected var _tilesets:Array = new Array();		protected var _tilespawns:Array = new Array();		protected var _mapsURL:String;				public function MapHandler() {			// constructor code		}		/**		 *		 * Loads the tilesets from the provided URLS.		 *		 * @param tilesetsURL The URL to the tilesets JSON		 * @param mapsURL THe URL to the maps JSON		 *		 */		 		public function load(tilesetsURL:String, mapsURL:String):void {			this._mapsURL = mapsURL;			this.loadObject(tilesetsURL, this.handleLoadedTilesets);			this.addEventListener(MapDataEvent.TILESETS_LOADED, this.loadMaps);		}				/**		 *		 * Load the maps after the tilesets are loaded.		 *		 */				public function loadMaps(event:MapDataEvent):void {			this.loadObject(this._mapsURL, this.handleLoadedMaps);		}				public function loadObject(url:String, handleFunction:Function):void {			var request:URLRequest = new URLRequest(url);			this._urlLoader.addEventListener(Event.COMPLETE, handleFunction);			this._urlLoader.load(request);		}				/**		 *		 * Handles the loaded tileset fromt the URLLoader		 *		 */		 		public function handleLoadedTilesets(event:Event):void {			this._urlLoader.removeEventListener(Event.COMPLETE, this.handleLoadedTilesets);						var tilesetData:Object = JSON.decode(this._urlLoader.data, true);			var tilesets:Object = tilesetData["tileset"];						for each(var tileset:Object in tilesets) {				this._tilesets[tileset["id"]] = new Array();				this._tilespawns[tileset['id']] = new Array();				for each(var tile:Object in tileset["tile"]) {					this._tilesets[tileset["id"]][tile["id"]] = tile["flashClass"];					if( tile.hasOwnProperty('spawnClass')) {						this._tilespawns[tileset['id']][tile['id']] = tile['spawnClass'];					} else {						this._tilespawns[tileset['id']][tile['id']] = "";					}					}			}						this.dispatchEvent(new MapDataEvent(MapDataEvent.TILESETS_LOADED));		}				/**		 *		 * Handles the loaded map from the URLLoader.		 *		 */		 		public function handleLoadedMaps(event:Event):void {			this._urlLoader.removeEventListener(Event.COMPLETE, this.handleLoadedMaps);						var mapData:Object = JSON.decode(this._urlLoader.data, true);			var maps:Object = mapData["map"];						for each(var map:Object in maps) {				this._maps[map["id"]] = new Map(map["id"], map["name"], this._tilesets[map["tilesetID"]], this._tilespawns[map['tilesetID']], map["tile"]);			}						this.dispatchEvent(new MapDataEvent(MapDataEvent.MAPS_LOADED, true));		}				/**		 *		 * Fetches a map.		 * 		 * @param mapID The ID of the map.		 * 		 * @return The <code>Map</code> object for the passed <code>mapID</code>/		 *		 */				public function getMap(mapID:Number) {			return this._maps[mapID];		}	}	}