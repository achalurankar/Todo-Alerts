import { LightningElement } from 'lwc';

export default class TodoLwc extends LightningElement {

    renderedCallback() {
        let ul = this.template.querySelector('ul');
        let code = ul.innerHTML;
        let newCode = "";
        for(let i = 0; i < 5; i++) {
            newCode += code;
        }
        ul.innerHTML = newCode;
    }
}