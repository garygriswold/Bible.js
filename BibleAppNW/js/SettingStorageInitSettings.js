SettingStorage.prototype.initSettings = function() {
	this.setVersion("ARBVDPD", "ARBVDPD.db");
	this.setVersion("KJVPD", "KJVPD.db");
	this.setVersion("NMV", "NMV.db");
	this.setVersion("WEB", "WEB.db");
	this.removeVersion("CUVSPD");
	this.removeVersion("CUVTPD");
};
SettingStorage.prototype.defaultVersion = function(lang) {
	switch(lang) {
		case "ar": return("ARBVDPD.db");
		case "fa": return("NMV.db");
		case "en": return("WEB.db");
		default: return("WEB.db");
	}
};
