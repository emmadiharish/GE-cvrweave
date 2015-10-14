/**
* @author Zoran Zunko
* @date 10/7/15
*
* @group 
* @group-content ../../ApexDocContent/
*
* @description 
*/

public with sharing class CVCaseCreationSectionComponentCtrl {

    public CaseNewWFControllerExtBase pageController {get; set;}

    public Map<String, FieldSet> sectionFieldSetMap {

        get { return pageController.getSectionFieldSetMap(); }
    }

    public Case cNewCase {

        get { return pageController.cNewCase; }
    }

}