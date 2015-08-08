#echo \"use strict\"\; > app/Database.js

cp ../Library/io/IOError.js app/io/IOError.js
echo "module.exports = IOError;" >> app/io/IOError.js
cp ../Library/io/DeviceDatabaseNative.js app/io/DeviceDatabase.js
echo "module.exports = DeviceDatabase;" >> app/io/DeviceDatabase.js
cp ../Library/io/ChaptersAdapter.js app/io/ChaptersAdapter.js
echo "module.exports = ChaptersAdapter;" >> app/io/ChaptersAdapter.js

tns run ios --emulator
#npm start
