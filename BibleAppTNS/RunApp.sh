#echo \"use strict\"\; > app/Database.js

cp ../Library/io/IOError.js app/io/IOError.js
echo "module.exports = IOError;" >> app/io/IOError.js
cp ../Library/io/DeviceDatabaseNative.js app/io/DeviceDatabase.js
echo "module.exports = DeviceDatabase;" >> app/io/DeviceDatabase.js
#echo "exports.IOError = IOError;" >> app/app.js
#echo "exports.DeviceDatabase = DeviceDatabase;" >> app/app.js

#cat app/app_original.js >> app/app.js

tns run ios --emulator
#npm start
