
if [ "${CONFIGURATION}" = "Release" ]
then
    echo "Release Build"
    exit
fi

if grep -l -r -i "Dai-Hentai" ~/Library/MobileDevice/Provisioning\ Profiles
then
    echo "Found"
    cp "`grep -l -r -i "Dai-Hentai" ~/Library/MobileDevice/Provisioning\ Profiles`" $SRCROOT/Dai-Hentai/Dai-Hentai.mobileprovision
fi
