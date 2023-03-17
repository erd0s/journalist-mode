# Increment the version number
RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "Journalist Mode/Info.plist")
MAJOR=`echo $buildNumber | sed -e "s#$RE#\1#"`
MINOR=`echo $buildNumber | sed -e "s#$RE#\2#"`
PATCH=`echo $buildNumber | sed -e "s#$RE#\3#"`
NEWPATCH=$(($PATCH + 1))
buildNumber="${MAJOR}.${MINOR}.${NEWPATCH}"
echo "Updating version to ${buildNumber}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "Journalist Mode/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $buildNumber" "Journalist Mode/Info.plist"

echo "Archiving app"
xcodebuild archive -workspace Journalist\ Mode.xcodeproj/project.xcworkspace -scheme "Journalist Mode"
