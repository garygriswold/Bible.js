SettingStorage.prototype.initSettings = function() {
	this.setVersion("ARBVDPD", "ARBVDPD.db");
	this.setVersion("CUVSPD", "CUVSPD.db");
	this.setVersion("CUVTPD", "CUVTPD.db");
	this.setVersion("KJVPD", "KJVPD.db");
	this.setVersion("WEB", "WEB.db");
};
SettingStorage.prototype.defaultVersion = function(lang) {
	switch(lang) {
		case "ar": return("ARBVDPD.db");
		case "zh": return("CUVTPD.db");
		case "en": return("WEB.db");
		default: return("WEB.db");
	}
};
