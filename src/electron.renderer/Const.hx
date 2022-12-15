class Const {
	static var APP_VERSION : String = #if macro getPackageVersion() #else getPackageVersionMacro() #end;

	public static function getAppVersion(short=false) {
		if( short )
			return APP_VERSION;
		else
			return [
				APP_VERSION,
				#if debug "debug", #end
				getArch(),
			].join("-");
	}

	public static function getAppBuildId() : Float {
		return Std.int(  dn.MacroTools.getBuildTimeStampSeconds() / (60*60)  );
	}

	public static function getArch() {
		#if macro
		return "";
		#else
		return switch js.Node.process.arch {
			case "x64": "64bits";
			case "x32": "32bits";
			case "ia32": "32bits";
			case _: "";
		}
		#end
	}

	public static function getElectronVersion() {
		#if macro
		return "";
		#else
		return js.Node.process.versions.get("electron");
		#end
	}

	public static function getJsonVersion() {
		return getAppVersion(true);
	}

	public static final APP_NAME = "LDtk";
	public static final FILE_EXTENSION = "ldtk";
	public static final LEVEL_EXTENSION = "ldtkl";
	public static final POINT_SEPARATOR = ",";
	public static final BACKUP_NAME_SUFFIX = ".backup";
	public static final BACKUP_DIR = "backups";
	public static final LEVEL_FILE_LEADER_ZEROS = 4;
	public static final DEFAULT_BACKUP_LIMIT = 10;

	// URLs: Deepnight games
	public static var DEEPNIGHT_DOMAIN = "https://deepnight.net";

	// URLs: LDtk home
	public static var LDTK_DOMAIN = "https://ldtk.io";
	public static var HOME_URL = LDTK_DOMAIN;
	public static var DOCUMENTATION_URL = LDTK_DOMAIN+"/docs";
	public static var DISCORD_URL = LDTK_DOMAIN+"/go/discord";

	// URLs: misc
	public static var DOWNLOAD_URL = HOME_URL;
	public static var ITCH_IO_BUY_URL = "https://deepnight.itch.io/ldtk/purchase";
	public static var ISSUES_URL = "https://github.com/deepnight/ldtk/issues";
	public static var REPORT_BUG_URL = "https://github.com/deepnight/ldtk/issues/new";
	public static var GITHUB_SPONSOR_URL = "https://github.com/sponsors/deepnight";
	public static var JSON_DOC_URL = LDTK_DOMAIN+"/json";
	public static var JSON_SCHEMA_URL = LDTK_DOMAIN+"/files/JSON_SCHEMA.json";

	public static function getContactEmail() {
		return "ldtk" + String.fromCharCode(64) + String.fromCharCode(100) + "eepnigh" + "t." + "ne"+"t";
	}


	#if !macro
	public static var JSON_HEADER = {
		fileType: Const.APP_NAME+" Project JSON",
		app: Const.APP_NAME,
		doc: JSON_DOC_URL,
		schema: JSON_SCHEMA_URL,
		appAuthor: "Sebastien 'deepnight' Benard",
		appVersion: getAppVersion(true),
		url: HOME_URL,
	}

	public static var APP_CHANGELOG_MD = getAppChangelogMarkdown();
	public static function getChangeLog() return new dn.Changelog(APP_CHANGELOG_MD);

	public static var JSON_FORMAT_MD = getJsonFormatMarkdown();

	public static var FPS = 60;
	public static var SCALE = 1.0;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get,never) : Int; static inline function get_NEXT_UNIQ() return _uniq++;
	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_UI = _inc++;
	public static var DP_TOP = _inc++;

	public static var MAX_GRID_SIZE = 1024;

	public static var NICE_PALETTE : Array<dn.Col> = [ // Credits: Endesga32 by Endesga (https://lospec.com/palette-list/endesga-32)
		0xbe4a2f,
		0xd77643,
		0xead4aa,
		0xe4a672,
		0xb86f50,
		0x733e39,
		0x3e2731,
		0xa22633,
		0xe43b44,
		0xf77622,
		0xfeae34,
		0xfee761,
		0x63c74d,
		0x3e8948,
		0x265c42,
		0x193c3e,
		0x124e89,
		0x0099db,
		0x2ce8f5,
		0xffffff,
		0xc0cbdc,
		0x8b9bb4,
		0x5a6988,
		0x3a4466,
		0x262b44,
		0x181425,
		0xff0044,
		0x68386c,
		0xb55088,
		0xf6757a,
		0xe8b796,
		0xc28569,
	];

	public static function suggestNiceColor(useds:Array<dn.Col>) : dn.Col {
		// Look in "Nice palette" for colors distinct from the ones in "useds" palette
		var pool = [];
		for(nice in NICE_PALETTE) {
			var ok = true;
			for(used in useds)
				if( nice.getDistanceRgb(used)<0.1 ) {
					ok = false;
					break;
				}
			if( ok )
				pool.push(nice);
		}

		if( pool.length==0 ) {
			// No match in Nice Palette, just build a new random color
			#if debug ui.Notification.debug("random"); #end
			return dn.Col.randomHSL(dn.RandomTools.rnd(0,1), dn.RandomTools.rnd(0.6,0.8), dn.RandomTools.rnd(0.7,1));
		}
		else {
			// Prefer colors that are not too bright or dark
			var dh = new dn.DecisionHelper(pool);
			for(uc in useds)
				dh.score( c->c.getDistanceRgb(uc)*0.5 );
			dh.score( c->c.fastLuminance>=0.4 && c.fastLuminance<=0.75 ? 50 : 0 );
			dh.score( c->dn.RandomTools.rnd(0,5) );
			return dh.getBest();
		}
	}

	public static var AUTO_LAYER_ANYTHING = 1000001;
	public static var MAX_AUTO_PATTERN_SIZE = 7;
	#end


	#if macro
	public static function dumpBuildVersionToFile() {
		var v = getAppVersion();
		sys.io.File.saveContent("lastBuildVersion.txt", v);
	}
	#end

	static function getPackageVersion() : String {
		var raw = sys.io.File.getContent("app/package.json");
		var json = haxe.Json.parse(raw);
		return json.version;
	}

	static macro function getPackageVersionMacro() {
		haxe.macro.Context.registerModuleDependency("Const","app/package.json");
		return macro $v{ getPackageVersion() };
	}

	static macro function getAppChangelogMarkdown() {
		haxe.macro.Context.registerModuleDependency("Const","docs/CHANGELOG.md");
		return macro $v{ sys.io.File.getContent("docs/CHANGELOG.md") };
	}

	static macro function getJsonFormatMarkdown() {
		haxe.macro.Context.registerModuleDependency("Const","docs/JSON_DOC.md");
		return macro $v{ sys.io.File.getContent("docs/JSON_DOC.md") };
	}

	static macro function buildLatestReleaseNotes() {
		// App latest changelog
		var raw = sys.io.File.getContent("docs/CHANGELOG.md");
		var appCL = new dn.Changelog(raw);
		var relNotes = [
			"# " + appCL.latest.version.full + ( appCL.latest.title!=null ? " -- *"+appCL.latest.title+"*" : "" ),
		].concat( appCL.latest.allNoteLines );

		// Save file
		if( !sys.FileSystem.exists("./app/buildAssets") )
			sys.FileSystem.createDirectory("./app/buildAssets");
		var relNotesPath = "./app/buildAssets/release-notes.md";
		var out = relNotes.join("\n");
		out = StringTools.replace(out, "![](", "![](https://ldtk.io/files/changelogImg/");
		try sys.io.File.saveContent(relNotesPath, out)
			catch(e:Dynamic) haxe.macro.Context.warning("Couldn't write "+relNotesPath, haxe.macro.Context.currentPos());

		return macro {}
	}
}
