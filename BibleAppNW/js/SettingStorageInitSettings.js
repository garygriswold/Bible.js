SettingStorage.prototype.initSettings = function() {
	this.setVersion("WEB", "WEB.db");
	this.setVersion("KJVPD", "KJVPD.db");
	this.setVersion("RVR09PD", "RVR09PD.db");
	this.setVersion("ARVDVPD", "ARVDVPD.db");
};
SettingStorage.prototype.defaultVersion = function(lang) {
	switch(lang) {
		case "en": return("WEB.db");
		case "es": return("RVR09PD.db");
		case "ar": return("ARVDVPD.db");
		default: return("WEB.db");
	}
};
