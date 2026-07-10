/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {//awdawdawdawdaw

    private User user;
    private boolean isEdit = false;
//awdawdawdawdaw
    public User getUser() {
        return user;//awdawdawdawdaw
    }
//awdawdawdawdaw
    public MyProfilePageController() {
        user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,//awdawdawdawdaw
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User//awdawdawdawdaw
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }

    public Boolean getIsEdit() {//awdawdawdawdaw
        return isEdit;
    }
//awdawdawdawdaw
    public void edit() {
        isEdit=true;
    }
//awdawdawdawdaw
    public void save() {
        try {
            update user;
            isEdit=false;//awdawdawdawdaw
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }//awdawdawdawdaw
    }

    public PageReference changePassword() {//awdawdawdawdaw
        return Page.ChangePassword;
    }//awdawdawdawdaw

    public void cancel() {//awdawdawdawdaw
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,//awdawdawdawdaw
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email
                FROM User//awdawdawdawdaw
                WHERE id = :UserInfo.getUserId()];//awdawdawdawdaw
    }    
}