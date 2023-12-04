import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';

export default class AlphaHomeSlider extends LightningElement {
    home_banner_3 = Zoetis_Static_Resources + '/images/home/home_banner_3.png'; 
    home_banner_2 = Zoetis_Static_Resources + '/images/home/home_banner_2.png'; 
    home_banner_new_1 = Zoetis_Static_Resources + '/images/home/home_banner_new_1.jpg';  
    renderedCallback() {

        Promise.all([
            loadScript(this, Zoetis_Static_Resources + '/js/jquery.min.js'),
            loadScript(this, Zoetis_Static_Resources + '/js/zoetis_global_scripts.js'),
            loadStyle(this, Zoetis_Static_Resources + '/css/zoetis_homepage_styles.css'),
        ])
            .then(() => {
                //alert('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
}