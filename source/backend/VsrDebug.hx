package backend;

/**
 * Test hooks (VSR_* environment variables) and the memory/fps logger only exist in debug builds
 * (built with -Dvsr_debug). In a release build env() is always null, so every hook is dead code.
 */
class VsrDebug
{
	public static inline var ON:Bool = #if vsr_debug true #else false #end;

	public static inline function env(name:String):Null<String>
	{
		#if vsr_debug
		return Sys.getEnv(name);
		#else
		return null;
		#end
	}
}
