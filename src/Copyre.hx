package;

import haxe.io.BytesInput;
import haxe.io.Eof;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileSeek;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class Copyre {
	static var pairs:Array<{ from:String, to:String }> = [];
	static function copyFile(s1:FullPath, s2:FullPath, r1:String, r2:String) {
		var stat = FileSystem.stat(s1);
		var changed = false;
		if (stat.size < 1024 * 1024) {
			//
			var fileInput = File.read(s1);
			var fileBytes = fileInput.readAll();
			fileInput.close();
			//
			var input = new BytesInput(fileBytes);
			var isText:Bool, text:String;
			try {
				input.readUntil(0);
				isText = false;
				text = null;
			} catch (_:Eof) {
				input.position = 0;
				isText = true;
				text = fileBytes.toString();
			}
			input.close();
			//
			if (isText) {
				if (text.indexOf(r1) >= 0) {
					text = text.replace(r1, r2);
					changed = true;
				}
				for (pair in pairs) if (text.indexOf(pair.from) >= 0) {
					text = text.replace(pair.from, pair.to);
					changed = true;
				}
				if (changed) File.saveContent(s2, text);
			}
		}
		if (!changed) File.copy(s1, s2);
	}
	static function randomGUID(upper:Bool = false) {
		var result = "";
		var chars = upper ? "0123456789ABCDEF" : "0123456789abcdef";
		for (j in 0 ... 32) {
			if (j == 8 || j == 12 || j == 16 || j == 20) {
				result += "-";
			}
			if (j == 12) {
				result += "4";
			}
			else if (j == 16) {
				result += (upper ? "89AB" : "89ab").charAt(Std.random(4));
			}
			else {
				result += chars.charAt(Std.random(16));
			}
		}
		return result;
	}
	static function copyDir(s1:FullPath, s2:FullPath, r1:String, r2:String) {
		FileSystem.createDirectory(s2);
		var oldPairs = null;
		if (FileSystem.exists(s1 + "/.copyre")) {
			oldPairs = pairs.copy();
			var text = File.getContent(s1 + "/.copyre");
			text = text.replace("\r", "");
			var lines = text.split("\n");
			var i = 0;
			var n = lines.length & ~1;
			while (i < n) {
				var from = lines[i++];
				if (from.trim() == "") continue;
				if (~/\s\/\/.+/.match(from)) continue;
				var to = lines[i++];
				to = ~/\$\{(newName|newname|NEWNAME)\}/.map(to, function(rx) {
					var s = rx.matched(1);
					if (s.unsafeCodeAt(0) == "N".code) return r2.toUpperCase();
					if (s.unsafeCodeAt(3) == "N".code) return r2;
					return r2.toLowerCase();
				});
				to = ~/\$\{(new_guid|NEW_GUID)\}/.map(to, function(rx) {
					return randomGUID(rx.matched(1).unsafeCodeAt(0) == "N".code);
				});
				pairs.push({from:from, to:to});
			}
		}
		for (ls in FileSystem.readDirectory(s1)) {
			if (ls == ".git") continue;
			if (ls == ".copyre") continue;
			var f1 = s1 + "/" + ls;
			var f2 = s2 + "/" + ls.replace(r1, r2);
			copyPath(f1, f2, r1, r2);
		}
		if (oldPairs != null) pairs = oldPairs;
	}
	static inline function copyPath(s1:FullPath, s2:FullPath, r1:String, r2:String) {
		Sys.println('<- $s1');
		Sys.println('-> $s2');
		if (FileSystem.isDirectory(s1)) {
			copyDir(s1, s2, r1, r2);
		} else copyFile(s1, s2, r1, r2);
	}
	static function main() {
		var args = Sys.args();
		if (args.length < 2) {
			Sys.println("Use: copyre path-from path-to [replace-from] [replace-to]");
			return;
		}
		var s1 = args[0];
		var s2 = args[1];
		var r1 = args[2]; if (r1 == null) r1 = Path.withoutDirectory(s1);
		var r2 = args[3]; if (r2 == null) r2 = Path.withoutDirectory(s2);
		if (!FileSystem.exists(s1)) {
			Sys.println('`$s1` does not exist!');
			return;
		} else copyPath(s1, s2, r1, r2);
	}
}
typedef FullPath = String;