@ECHO OFF
SET tooling_jar=tooling-cli-3.9.1.jar
SET input_cache_path=%~dp0input-cache
IF -%1-==-- (
	SET bundle=input\resources\bundle\tx
) ELSE (
	SET bundle=%1
)

SET JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF-8

IF EXIST "%input_cache_path%\%tooling_jar%" (
	ECHO running: JAVA -jar "%input_cache_path%\%tooling_jar%" -BundleToResources -p=%bundle% -v=r4 -op=%bundle% -db=false
	JAVA -jar "%input_cache_path%\%tooling_jar%" -BundleToResources -p=%bundle% -v=r4 -op=%bundle% -db=false
) ELSE If exist "..\%tooling_jar%" (
	ECHO running: JAVA -jar "..\%tooling_jar%" -BundleToResources -p=%bundle% -v=r4 -op=%bundle% -db=false
	JAVA -jar "..\%tooling_jar%" -BundleToResources -p=%bundle% -v=r4 -op=%bundle% -db=false
) ELSE (
	ECHO Tooling JAR NOT FOUND in input-cache or parent folder.  Please run _updateCQFTooling.  Aborting...
)

PAUSE