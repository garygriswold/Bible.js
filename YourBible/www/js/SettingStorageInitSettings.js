SettingStorage.prototype.initSettings = function() {
	this.setCurrentVersion("WEB.db");
	this.setVersion("KJVPD", "KJVPD.db");
	this.setVersion("WEB", "WEB.db");
	return("WEB.db");
};
