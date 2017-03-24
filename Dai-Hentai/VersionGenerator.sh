# Daidouji - this script is from https://github.com/alokc83/Xcode-build-and-version-generator/blob/master/xcode-build-number-generator.sh
# Daidouji - http://www.mactricksandtips.com/2010/01/working-with-the-date-function-in-terminal.html
# Daidouji - http://stackoverflow.com/questions/3614017/how-can-i-limit-a-run-script-build-phase-to-my-release-configuration

if [ "${CONFIGURATION}" = "Release" ]
then
    echo "Release Build"
    exit
fi

buildNumber=`date '+%Y%m%d'`

echo "Final Build number is $buildNumber"
echo "$plistFile"

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${INFOPLIST_FILE}"
