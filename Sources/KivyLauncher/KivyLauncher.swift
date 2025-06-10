

import PySwiftKit
import PySwiftObject
//// import PythonCore
import PythonLibrary
import PythonLauncher
import PathKit

import OSLog

#if os(iOS)
import UIKit
import KivyCore
#endif

public class _KivyLauncher: PyLauncher {
    public var PYTHON_VERSION: String = "3.11"
    
    
    let IOS_IS_WINDOWED: Bool = false
    public var KIVY_CONSOLELOG: Bool = true
    
    public var program: String?
    
    public var python_library: PathKit.Path
    
    public var site_packages: PathKit.Path
    
    public var other_site_packages: [PathKit.Path]
    
    public var pyswiftImports: [PySwiftModuleImport]
    
    public var env: PythonLauncher.PyEnvironment
    
    public func preLaunch() throws {
        pythonSettings()
        kivySettings()
    }
    
    public func onLaunch() throws {
        
    }

    
    public func onExit() throws {
        
    }
    
    func hmm() async {
        
    }
    
    init() {
        fatalError()
    }
    
}

extension _KivyLauncher {
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
        env.KIVY_BUILD = "ios"
        env.KIVY_WINDOW = "sdl2"
        env.KIVY_IMAGE = "imageio,tex,gif,sdl2"
        env.KIVY_AUDIO = "sdl2"
        env.KIVY_GL_BACKEND = "sdl2"
        
        // IOS_IS_WINDOWED=True disables fullscreen and then statusbar is shown
        env.IOS_IS_WINDOWED = IOS_IS_WINDOWED
        //#if DEBUG
        //putenv("KIVY_NO_CONSOLELOG=\(KIVY_NO_CONSOLELOG)")
        if !KIVY_CONSOLELOG {
            env.KIVY_NO_CONSOLELOG = "1"
        }
        //#endif
    }
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

public class KivyLauncher {
	
	let PYTHON_VERSION: String = "3.11"
	
	let IOS_IS_WINDOWED: Bool = false
	public var KIVY_CONSOLELOG: Bool = true
	public var prog: String
	public var site_packages: URL
	public var site_paths: [String]
	public var pyswiftImports: [PySwiftModuleImport]
	
	public var env = Environment()
	
	public init(site_packages: URL, site_paths: [URL], pyswiftImports: [PySwiftModuleImport]) throws {
        if #available(iOS 16, macOS 13, *) {
			self.site_paths = site_paths.map({$0.path()})
		} else {
			self.site_paths = site_paths.map(\.path)
		}
		self.site_packages = site_packages
		self.pyswiftImports = pyswiftImports
        #if os(iOS)
		self.pyswiftImports.append(.ios)
        
        #endif
        let YourApp = Bundle.main.url(forResource: "YourApp", withExtension: nil)!
        chdir(YourApp.path)
		if let _prog = Bundle.main.path(forResource: "YourApp/main", ofType: "pyc") {
			prog = _prog
		} else {
			throw CocoaError.error(.fileNoSuchFile)
		}
	}
	
	public func setup() {
		pythonSettings()
		kivySettings()
        #if os(iOS)
		export_orientation()
        #endif
		pythonHome()
		pySwiftImports()
	}
	public func start() {
		Py_Initialize()
	}
	
    private func pythonSettings() {
        env.PYTHONOPTIMIZE = 2
        env.PYTHONDONTWRITEBYTECODE = 1
        env.PYTHONNOUSERSITE = 1
        env.PYTHONPATH = "."
        #if os(iOS)

        
        env.PYTHONUNBUFFERED = 1
        env.LC_CTYPE = "UTF-8"
        // putenv("PYTHONVERBOSE=1")
        // putenv("PYOBJUS_DEBUG=1")
        #endif
    }
    
    private func kivySettings() {
        // Kivy environment to prefer some implementation on iOS platform
        //putenv("KIVY_BUILD=ios")
        #if os(iOS)
        env.KIVY_BUILD = "ios"
//        putenv("KIVY_WINDOW=sdl2")
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
        #endif
        if !KIVY_CONSOLELOG {
            env.KIVY_NO_CONSOLELOG = "1"
        }
        //#endif
    }
	
	private func pythonHome() {
		
		let resourcePath = Bundle.main.resourceURL!
        #if os(iOS)
		let python_root = PythonLibrary.home.bundleURL
	
		env.PYTHONHOME = python_root.path
		
		let site_paths = "\(site_paths.joined(separator: ":"))"
		let python_lib = python_root.appendingPathComponent("lib")
		//let site_packages = resourcePath.appendingPathComponent("site-packages")
		
		env.PYTHONPATH = "\(python_root.path):\(python_lib.path):\(site_packages):."
        #else
        let python_root = Bundle.main.resourceURL!
        
        
        env.PYTHONHOME = resourcePath.path
        
        let python_lib = python_root.appendingPathComponent("lib")
        env.PYTHON_LIBRARY = python_lib.path
        //let site_packages = resourcePath.appendingPathComponent("site-packages")
        
        env.PYTHONPATH = "\(python_root.path):\(python_lib.path):\(site_packages):."
        #endif
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
        #if os(iOS)
		env.KIVY_ORIENTATION = result
        #endif
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
        #if os(iOS)
		load_custom_builtin_importer()
        #endif
        var fd: UnsafeMutablePointer<FILE>?
		var ret: Int32
        
        DispatchQueue.global().sync {
            fd = fopen(prog, "r")
        }
        
		if let fd {
			
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

//
//
//@freestanding(declaration, names: arbitrary)
//public macro SDL2Main(_ closure: (_ kivy: KivyLauncher)->Void) = #externalMacro(module: "KivyLauncherMacros", type: "CreateSDL2Main")
