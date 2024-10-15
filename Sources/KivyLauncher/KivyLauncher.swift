//
//  SDL_main.swift
//  Kivy-iOS
//
//

import UIKit
import PySwiftCore
import PySwiftObject
//// import PythonCore
import PythonLibrary



//fileprivate
//func putenv(_ s: String) {
//	let _count = s.utf8.count + 1
//	let result = UnsafeMutablePointer<Int8>.allocate(capacity: _count)
//	s.withCString { (baseAddress) in
//		result.initialize(from: baseAddress, count: _count)
//	}
//	
//	putenv(result)
//}
//

@dynamicMemberLookup
struct KivyEnvironment {
	
	subscript(dynamicMember key: String) -> String? {
		get {
			if let result = key.withCString(getenv) {
				return .init(cString: result)
			}
			return nil
		}
		set {
			_ = key.withCString { _key in
				setenv(_key, newValue, 1)
			}
		}
	}
	
	subscript(dynamicMember key: String) -> Int? {
		get {
			if let result = key.withCString(getenv) {
				return .init(String(cString: result))
			}
			return nil
		}
		set {
			key.withCString { _key in
				if let newValue = newValue {
					setenv(_key, String(newValue), 1)
					return
				}
				setenv(_key, nil, 1)
			}
		}
	}
	subscript(dynamicMember key: String) -> Bool? {
		get {
			if let result = key.withCString(getenv) {
				return .init(String(cString: result).lowercased())
			}
			return nil
		}
		set {
			key.withCString { _key in
				if let newValue = newValue, let boolValue = newValue ? "True" : "False" {
					setenv(_key, boolValue, 1)
					return
				}
				setenv(_key, nil, 1)
			}
		}
	}
	
}

var env = KivyEnvironment()


public class KivyLauncher {
	
	let PYTHON_VERSION: String = "3.11"
	
	let IOS_IS_WINDOWED: Bool = false
	public var KIVY_CONSOLELOG: Bool = true
	public var prog: String
	public var site_paths: [String]
	public var pyswiftImports: [PySwiftModuleImport]
	
	
	public init(site_paths: [URL], pyswiftImports: [PySwiftModuleImport]) throws {
		if #available(iOS 16, *) {
			self.site_paths = site_paths.map({$0.path()})
		} else {
			self.site_paths = site_paths.map(\.path)
		}
		self.pyswiftImports = pyswiftImports
		chdir("YourApp")
		
		if let _prog = Bundle.main.path(forResource: "YourApp/main", ofType: "pyc") {
			prog = _prog
		} else {
			throw CocoaError.error(.fileNoSuchFile)
		}
	}
	
	public func setup() {
		pythonSettings()
		kivySettings()
		export_orientation()
		pythonHome()
		pySwiftImports()
		Py_Initialize()
	}
	
	private func pythonSettings() {
		
		//putenv("PYTHONOPTIMIZE=2")
		env.PYTHONOPTIMIZE = 2
		//putenv("PYTHONDONTWRITEBYTECODE=1")
		env.PYTHONDONTWRITEBYTECODE = 1
		//putenv("PYTHONNOUSERSITE=1")
		env.PYTHONNOUSERSITE = 1
		//putenv("PYTHONPATH=.")
		env.PYTHONPATH = "."
		//putenv("PYTHONUNBUFFERED=1")
		env.PYTHONUNBUFFERED = 1
		//putenv("LC_CTYPE=UTF-8")
		env.LC_CTYPE = "UTF-8"
		// putenv("PYTHONVERBOSE=1")
		// putenv("PYOBJUS_DEBUG=1")
	}
	
	private func kivySettings() {
		// Kivy environment to prefer some implementation on iOS platform
		//putenv("KIVY_BUILD=ios")
		env.KIVY_BUILD = "ios"
//		putenv("KIVY_WINDOW=sdl2")
		env.KIVY_WINDOW = "sdl2"
		//putenv("KIVY_IMAGE=imageio,tex,gif,sdl2")
		env.KIVY_IMAGE = "imageio,tex,gif,sdl2"
		//putenv("KIVY_AUDIO=sdl2")
		env.KIVY_AUDIO = "sdl2"
		//putenv("KIVY_GL_BACKEND=sdl2")
		env.KIVY_GL_BACKEND = "sdl2"
		
		// IOS_IS_WINDOWED=True disables fullscreen and then statusbar is shown
		//putenv("IOS_IS_WINDOWED=\(IOS_IS_WINDOWED ? "True" : "False")")
		env.IOS_IS_WINDOWED = IOS_IS_WINDOWED
		//#if DEBUG
		//putenv("KIVY_NO_CONSOLELOG=\(KIVY_NO_CONSOLELOG)")
		env.KIVY_NO_CONSOLELOG = KIVY_CONSOLELOG ? "0" : "1"
		//#endif
	}
	
	private func pythonHome() {
		
		let resourcePath = Bundle.main.resourceURL!
		
		let python_root = PythonLibrary.home.bundleURL
		
		//let python_home = "PYTHONHOME=\(python_root.path)"
		//putenv(python_home)
		env.PYTHONHOME = python_root.path
		
		
		let site_paths = "\(site_paths.joined(separator: ":"))"
		let python_lib = python_root.appendingPathComponent("lib")
		//let lib_parent = python_lib.deletingLastPathComponent()
		let site_packages = resourcePath.appendingPathComponent("site-packages")
		
		//let python_path = "PYTHONPATH=\(python_root.path):\(python_lib.path):\(site_packages):."
		//putenv(python_path)
		env.PYTHONPATH = "\(python_root.path):\(python_lib.path):\(site_packages):."
		
		
		
		
		
	}
	
	private func pySwiftImports() {
		// add PySwiftMpdules to Python's import list
		for _import in pyswiftImports {
#if DEBUG
			print("Importing PySwiftModule:",String(cString: _import.name))
#endif
			if PyImport_AppendInittab(_import.name, _import.module) == -1 {
				PyErr_Print()
				fatalError()
			}
		}
	}
	
	private func export_orientation() {
		let info = Bundle.main.infoDictionary
		let orientations = info?["UISupportedInterfaceOrientations"] as? [AnyHashable]
		//var result = "KIVY_ORIENTATION="
		var result = ""
		for i in 0..<(orientations?.count ?? 0) {
			var item = orientations?[i] as? String
			item = (item as NSString?)?.substring(from: 22)
			if i > 0 {
				result = result + " "
			}
			result = result + (item ?? "")
		}
		
		//putenv(result)
		env.KIVY_ORIENTATION = result
#if DEBUG
		print("Available orientation: \(result)")
#endif
	}
	
	
	@discardableResult
	private func load_custom_builtin_importer() -> Int32 {
		"""
		import sys, imp, types
		from os import environ
		from os.path import exists, join
		try:
			# python 3
			import _imp
			EXTS = _imp.extension_suffixes()
			sys.modules['subprocess'] = types.ModuleType(name='subprocess')
			sys.modules['subprocess'].PIPE = None
			sys.modules['subprocess'].STDOUT = None
			sys.modules['subprocess'].DEVNULL = None
			sys.modules['subprocess'].CalledProcessError = Exception
			sys.modules['subprocess'].check_output = None
		except ImportError:
			EXTS = ['.so']
		# Fake redirection to supress console output
		if environ.get('KIVY_NO_CONSOLE', '0') == '1':
			class fakestd(object):
				def write(self, *args, **kw): pass
				def flush(self, *args, **kw): pass
			sys.stdout = fakestd()
			sys.stderr = fakestd()
		# Custom builtin importer for precompiled modules
		class CustomBuiltinImporter(object):
			def find_module(self, fullname, mpath=None):
				# print(f'find_module() fullname={fullname} mpath={mpath}')
				if '.' not in fullname:
					return
				if not mpath:
					return
				part = fullname.rsplit('.')[-1]
				for ext in EXTS:
				   fn = join(list(mpath)[0], '{}{}'.format(part, ext))
				   # print('find_module() {}'.format(fn))
				   if exists(fn):
					   return self
				return
			def load_module(self, fullname):
				f = fullname.replace('.', '_')
				mod = sys.modules.get(f)
				if mod is None:
					# print('LOAD DYNAMIC', f, sys.modules.keys())
					try:
						mod = imp.load_dynamic(f, f)
					except ImportError:
						# import traceback; traceback.print_exc();
						# print('LOAD DYNAMIC FALLBACK', fullname)
						mod = imp.load_dynamic(fullname, fullname)
					sys.modules[fullname] = mod
					return mod
				return mod
		sys.meta_path.insert(0, CustomBuiltinImporter())
		""".withCString(PyRun_SimpleString)
	}
	
	public func run_main(_ argc: Int32, _ argv: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>) throws -> Int32 {
		
		let _argc = Int(argc)
		let python_argv = PyMem_RawMalloc(MemoryLayout<UnicodeScalar>.size * _argc)!
		let _python_argv = python_argv.bindMemory(to: UnsafeMutablePointer<wchar_t>?.self, capacity: _argc)
		for i in 0..<_argc {
			_python_argv[i] = Py_DecodeLocale(argv[i], nil)
		}
		//PySys_SetArgv(argc, _python_argv)
		
		load_custom_builtin_importer()
		
		//let prog = Bundle.main.path(forResource: "YourApp/main", ofType: "pyc")!
		var ret: Int32
		if let fd = fopen(prog, "r") {
			
#if DEBUG
			print("Running main.py: \(prog)")
#endif
			
			ret = PyRun_SimpleFileEx(fd, prog, 1)
			NSLog("App ended")
			PyErr_Print()
			fclose(fd)
			
		} else {
			ret = 1
			NSLog("Unable to open main.py, abort.")
		}
		
		Py_Finalize()
		return ret
	}
}



