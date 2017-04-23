var ISO3 = 'eng';
var ISO2 = 'en';
var ISO_NAME = 'English';

var languageList = {
	showView: function() {
		
		var div = document.createElement('div');
		div.setAttribute('class', 'langSelect');
		document.body.appendChild(div);
		
		var title = document.createElement('p');
		title.setAttribute('class', 'langTitle');
		title.innerText = ISO3 + ', ' + ISO2 + ', ' + ISO_NAME;
		div.appendChild(title);
		
		var para = document.createElement('p');
		para.setAttribute('class', 'langSelect');
		para.textContent = 'The Bible App will always play videos in the same language that the user is reading, ' +
		'but for demonstration purposes you can select a language.';
		div.appendChild(para);
		
		var select = document.createElement('select');
		select.setAttribute('class', 'langSelect');
		select.setAttribute('size', 3);
		select.setAttribute('prompt', 'XXX');
		div.appendChild(select);
		
		var prompt = document.createElement('option');
		prompt.setAttribute('disabled', 'disabled');
		prompt.setAttribute('selected', 'selected');
		prompt.textContent = 'Choose Language';
		select.appendChild(prompt);
		
		var useLanguages = kogLanguages;
		// var useLanguages = languages;
		for (var i=0; i<useLanguages.length; i++) {
			var option = document.createElement('option');
			option.setAttribute('value', useLanguages[i][0]);
			option.textContent = useLanguages[i][1];
			select.appendChild(option);
		}
		
		select.addEventListener('change', function(event) {
			console.log('CHANGE language selector ' + this.selected, this.selectedIndex);
			var lang = useLanguages[this.selectedIndex - 1];
			console.log('SELECTED ' + lang);
			var parts = lang[0].split('-');
			ISO2 = parts[0];
			ISO3 = parts[1];
			ISO_NAME = lang[1];
			var controller = new VideoController(ISO3, ISO2, 'US');
			controller.begin();
			
		});
	}
}
var kogLanguages = [
		//["sq-alb", "Albanian"], // Albanian
		["ar-arb", "Arabic"], // Arabic
		["gax-gax", "Borana"], // Borana
		["zh-cmn", "Chinese Mandarin"], // Mandarin Chinese
		["en-eng", "English"], // English
		["fr-fra", "French"], // French
		["ko-kor", "Korean"], // Korean
		["ky-kir", "Kyrgyz"], // Kyrgyz
		//["", "Lebanese"], // Lebanese
		["so-som", "Somali"], // Somali
		["es-spa", "Spanish"], // Spanish
		["sw-swh", "Swahili"], // Swahili
		["tr-tur", "Turkish"], // Turkish
		["ur-urd", "Urdu"], // Urdu
		["uz-uzb", "Uzbek"], // Uzbek
		["wo-wol", "Wolof"], // Wolof
		["dje-dje", "Zarma"]  // Zarma	
];


var languages = [
		["aa-aar", "Afar"],
		["af-afr", "Afrikaans"],// android
		["ak-aka", "Akan"],
		//["sq-alb", "Albanian"], // sqi macro
		["am-amh", "Amharic"],
		["ar-arb", "Arabic"], // ara Macro // iphone
		["hy-hye", "Armenian"],
		["as-asm", "Assamese"],
		["av-ava", "Avaric"],
		["awa-awa", "Awadhi"],
		["bm-bam", "Bambara"],
		["ba-bak", "Bashkir"],
		["eu-eus", "Basque"],
		["be-bel", "Belarusian"],
		["bn-ben", "Bengali"],
		//["bh-bih", "Bihari"], // not even found in SIL list
		["bi-bis", "Bislama"],
		["gax-gax", "Borana"],
		["bs-bos", "Bosnian"],
		["br-bre", "Breton"],
		["bg-bul", "Bulgarian"],
		["my-mya", "Burmese"],
		["ca-cat", "Catalan"],// iphone // android
		["ch-cha", "Chamorro"],
		["ce-che", "Chechen"],
		["zh-cmn", "Chinese Mandarin"], // zho macro // iphone
		["zh-yue", "Chinese Cantonese"], // zho macro // iphone
		["zh-nan", "Chinese Minnan"], // zho macro // iphone
		["cv-chv", "Chuvash"],
		["hr-hrv", "Croatian"],// iphone // android
		["cs-ces", "Czech"],// iphone
		["da-dan", "Danish"],// iphone // android
		["dv-div", "Dhivehi"],
		["nl-nld", "Dutch"],// iphone // android
		["en-eng", "English"], // iphone // android
		["et-ekk", "Estonian"], // est Macro
		["ee-ewe", "Ewe"],
		["fo-fao", "Faroese"],
		["fj-fij", "Fijian"],
		["fi-fin", "Finnish"],// iphone
		["fr-fra", "French"], // iphone // android
		["gl-glg", "Galician"],
		["lg-lug", "Ganda"],
		["ka-kat", "Georgian"],
		["de-deu", "German"], // iphone // android
		["el-ell", "Modern Greek"],// iphone // android
		["gu-guj", "Gujarati"],
		["ht-hat", "Haitian"],
		["ha-hau", "Hausa"],
		["he-heb", "Hebrew"],// iphone
		["hz-her", "Herero"],
		["hi-hin", "Hindi"],// iphone
		["ho-hmo", "Hiri Motu"],
		["hu-hun", "Hungarian"],// iphone
		["is-isl", "Icelandic"],
		["ig-ibo", "Igbo"],
		["id-ind", "Indonesian"],// iphone // android
		["iu-ike", "Inuktitut"], // macro iku
		["ga-gle", "Irish"],
		["it-ita", "Italian"],// iphone // android
		["ja-jpn", "Japanese"],
		["jv-jav", "Javanese"],
		["kl-kal", "Kalaallisut"],
		["kn-kan", "Kannada"],
		["ks-kas", "Kashmiri"],
		["kk-kaz", "Kazakh"],
		["km-khm", "Central Khmer"],
		["ki-kik", "Kikuyu"],
		["rw-kin", "Kinyarwanda"],
		["ky-kir", "Kirghiz"],
		["kg-kwy", "Kongo"], // macro kon
		["ko-kor", "Korean"],// iphone
		["kj-kua", "Kuanyama"],
		["ky-kir", "Kyrgyz"],
		["lo-lao", "Lao"],
		["lv-lav", "Latvian"], // android
		["ln-lin", "Lingala"],
		["lt-lit", "Lithuanian"], // android
		["lu-lub", "Luba-Katanga"],
		["mk-mkd", "Macedonian"],
		//["ms-zsm", "Malay"], //macro msa // iphone // android
		["ml-mal", "Malayalam"],
		["mt-mlt", "Maltese"],
		["mi-mri", "Maori"],
		["mr-mar", "Marathi"],
		["mh-mah", "Marshallese"],
		["mn-khk", "Mongolian"], // macro mon
		["na-nau", "Nauru"],
		["nv-nav", "Navajo"],
		["nd-nde", "North Ndebele"],
		["nr-nbl", "South Ndebele"],
		["ne-npi", "Nepali"], // macro nep
		["no-nor", "Norwegian"],
		//["nb-nob", "Norwegian Bokmål"],// iphone // android
		["ny-nya", "Nyanja"],
		["os-oss", "Ossetian"],
		["pa-pan", "Panjabi"],
		["fa-pes", "Persian"], // macro language fas  or try pes
		["pl-pol", "Polish"],// iphone // android
		["pt-por", "Portuguese"], // iphone // android
		["rn-run", "Rundi"],
		["ro-ron", "Romanian"],// iphone // android
		["ru-rus", "Russian"],// iphone // android
		["sm-smo", "Samoan"],
		["sg-sag", "Sango"],
		["gd-gla", "Scottish Gaelic"],
		["sr-srp", "Serbian"],
		["sn-sna", "Shona"],
		["ii-iii", "Sichuan Yi"],
		["sd-snd", "Sindhi"],
		["si-sin", "Sinhala"],
		["sk-slk", "Slovak"],// iphone // android
		["sl-slv", "Slovenian"],// android
		["so-som", "Somali"],// android
		["st-sot", "Southern Sotho"],
		["es-spa", "Spanish"],// iphone // android
		["su-sun", "Sundanese"],
		["sw-swh", "Swahili"], // macro swa
		["ss-ssw", "Swati"],
		["sv-swe", "Swedish"],// iphone
		["tl-tgl", "Tagalog"],
		["ty-tah", "Tahitian"],
		["tg-tgk", "Tajik"],
		["ta-tam", "Tamil"],
		["tt-tat", "Tatar"],
		["te-tel", "Telugu"],
		["th-tha", "Thai"],// iphone
		["bo-bod", "Tibetan"],
		["ti-tir", "Tigrinya"],
		["to-ton", "Tonga"],
		["ts-tso", "Tsonga"],
		["tn-tsn", "Tswana"],
		["tr-tur", "Turkish"],// iphone // android
		["tk-tuk", "Turkmen"],
		["ug-uig", "Uighur"],
		["uk-ukr", "Ukrainian"],// iphone
		["ur-urd", "Urdu"],
		["uz-uzb", "Uzbek"],
		["ve-ven", "Venda"],
		["vi-vie", "Vietnamese"],// iphone // android
		["cy-cym", "Welsh"],
		["wo-wol", "Wolof"],
		["xh-xho", "Xhosa"],
		["yo-yor", "Yoruba"],
		["dje-dje", "Zarma"],
		["zu-zul", "Zulu"] // android
];
