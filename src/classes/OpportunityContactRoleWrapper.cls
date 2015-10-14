public class OpportunityContactRoleWrapper
{
    public String oppId {get; set;}
    public String contactId {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String name{get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String accountType {get; set;}
    public String roleId {get; set;}
    public String role {get; set;}
    public Boolean isPrimary {get; set;}
    
    public void setContactId(String contactId)
    {
        this.contactId = contactId;
    }
    public void setEmail(String email)
    {
        this.email = email;
    }
    public void setPhone(String phone)
    {
        this.phone = phone;
    }
    public void setAccountType(String accountType)
    {
        this.accountType = accountType;
    }    
    public void setRoleId(String roleId)
    {
        this.roleId = roleId;
    }        
    public void setRole(String role)
    {
        this.role = role;
    }
    public void setPrimary(Boolean isPrimary)
    {
        this.isPrimary = isPrimary;
    }
    public void setOppId(String oppId)
    {
        this.oppId = oppId;
    }
    public void setFirstName(String firstName)
    {
        this.firstName = firstName;
    }
    public void setLastName(String lastName)
    {
        this.lastName = lastName;
    }
    public String getName()
    {
        return this.name;
    }
    public void setName(String name)
    {
        this.name = name;
    }
}