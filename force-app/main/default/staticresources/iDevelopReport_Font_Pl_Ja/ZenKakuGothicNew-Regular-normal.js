var callAddFont = function () {
this.addFileToVFS('ZenKakuGothicNew-Regular-normal.ttf', font);
this.addFont('ZenKakuGothicNew-Regular-normal.ttf', 'ZenKakuGothicNew', 'normal');
};
jspdf.jsPDF.API.events.push(['addFonts', callAddFont])