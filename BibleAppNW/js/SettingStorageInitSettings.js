SettingStorage.prototype.defaultVersion = function(lang) {
	switch(lang) {
		case "ar": return("ARBVDPD.db");
		case "fa": return("NMV.db");
		case "en": return("WEB.db");
		default: return("WEB.db");
	}
};
