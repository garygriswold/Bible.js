/**
* This class presents a Rate Me button and responds to clicks to that button.
*
*/
function RateMeView(version) {
	this.version = version;
	this.appName = 'SafeBible';
	this.appIdIos = "1073396349";
	this.appIdAndroid = "com.shortsands.yourbible";
	this.dom = new DOMBuilder();
	Object.seal(this);
}
RateMeView.prototype.showView = function() {
	var rateBtn = document.getElementById('ratebtn');
	if (rateBtn == null) {
		this._buildView();
	}
};
RateMeView.prototype._buildView = function() {
	var that = this;
	var table = document.getElementById('settingsTable');
	var row = this.dom.addNode(table, 'tr');
	var cell = this.dom.addNode(row, 'td');
	cell.setAttribute('style', 'text-align: center');
	var buttonText = this._getButtonText(this.version.langCode);
	var button = this.dom.addNode(cell, 'button', null, buttonText, 'ratebtn');
	button.addEventListener('click', function(event) {
		callNative('Utility', 'rateApp', [], 'N', function() {
			console.log("RATE ME COMPLETE");
		});
	});
};
RateMeView.prototype._getButtonText = function(langCode) {
	var buttonText = {
		'ar': "قيِّم %@",
		'bn': "রেট %@",
		'ca': "Ressenya %@",
		'cs': "Ohodnotit %@",
		'da': "Vurdér %@",
		'de': "Bewerte %@",
		'de-AT': "Bewerte %@",
		'el': "Αξιολόγησε %@",
		'en': "Rate %@",
		'es': "Reseña %@",
		'fa': "نرخ %@",
		'fi': "Arvostele %@",
		'fr': "Notez %@",
		'he': "דרג את %@",
		'hi': "दर %@",
		'id': "Beri Nilai %@",
		'it': "Valuta %@",
		'ja': "%@の評価",
		'ko': "%@ 평가하기",
		'nl': "Beoordeel %@",
		'no': "Vurder %@",
		'pa': "ਦਰ %@",
		'pl': "Oceń %@",
		'pt': "Avaliar %@",
		'ru': "Оцените %@",
		'sk': "Ohodnotiť %@",
		'sl': "Oceni %@",
		'sv': "Betygsätt %@",
		'th': "อัตรา %@",
		'tr': "Oy %@",
		'uk': "Оцінити %@",
		'ur': "شرح %@",
		'ur-IN': "کو ریٹ کیجیے %@",
		'ur-PK': "کو ریٹ کیجیے %@",
		'vi': "Đánh giá %@",
		'zh': "为“%@”评分",
		'zh-TW': "評分 %@",
		'zh-Hans': "为“%@”评分",
		'zh-Hant': "評分 %@" };
	var message = buttonText[langCode];
	if (message == null) message = buttonText['en'];
	message = message.replace('%@', this.appName);
	return(message);
};