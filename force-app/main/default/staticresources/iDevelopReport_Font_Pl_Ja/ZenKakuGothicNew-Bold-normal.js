var callAddFont = function () {
this.addFileToVFS('ZenKakuGothicNew-Bold-normal.ttf', font);
this.addFont('ZenKakuGothicNew-Bold-normal.ttf', 'ZenKakuGothicNew', 'bold');
};
jspdf.jsPDF.API.events.push(['addFonts', callAddFont])