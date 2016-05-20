SettingStorage.prototype.initSettings = function() {
	this.setVersion("KJVPD", "KJVPD.db");
	this.setVersion("WEB", "WEB.db");
	this.setCurrentVersion("WEB.db");
};
