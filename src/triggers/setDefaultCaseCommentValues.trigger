trigger setDefaultCaseCommentValues on CaseComment (before insert, before update) {
    for(CaseComment cc : Trigger.New){
        if(cc.IsPublished==false){
            cc.IsPublished=true;
        }
    }
}