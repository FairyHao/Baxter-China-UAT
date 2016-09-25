/**
 * Author: Sunny
 * 自动设置协访质量点评的所有人为被点评人
 */
trigger AutoSetAssVisitOwner on AssVisitComments__c (before insert) {
    for(AssVisitComments__c assVisit : trigger.new){
    	if(assVisit.BeReviewed__c != null){
    		assVisit.OwnerId = assVisit.BeReviewed__c;
    	}
    }
}