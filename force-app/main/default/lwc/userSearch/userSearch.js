
import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserInfo from '@salesforce/apex/UserSearchController.getUserInfo';

export default class UserSearch extends LightningElement {
    @track user = {
        firstName : '',
        lastName : '',
        email : ''
    };


    handleClick(){
        this.getUserInfo();
    }

    getUserInfo(){

        getUserInfo({searchKey : this.userId })
        .then(result => {
            if(result === 'Not Found')
                this.handleNoResult();
            else
                this.parseJson2Obj(result);
        })
        .catch(error => {
            this.errorMsg = error;
        });
    }

    get userId(){
        let el = this.template.querySelector('.user-search');
        return el? el.value : '';
    }

    parseJson2Obj(result){
        const user = JSON.parse(result);
        let nameList = [];
        if(user.name)
            nameList = user.name.split(' ');
        this.user.firstName = nameList[0];
        this.user.lastName = nameList[1];
        this.user.email = user.email;

    }

    handleSuccess(){
        const evt = new ShowToastEvent({
            message: 'Contact Created Successfully!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    handleNoResult(){
        const evt = new ShowToastEvent({
            message: 'No Contact Found',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
    }
}