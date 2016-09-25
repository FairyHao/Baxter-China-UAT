/**
 * Author: Sunny
 * 自动设置业务机会策略评估的所有人为业务机会所有人（代表）
 */
trigger AutoSetOppEvaluationOwner on OppEvaluation__c (before insert) {
    for(OppEvaluation__c OppEva : trigger.new){
        if(OppEva.BeCommentUser__c != null){
            OppEva.OwnerId = OppEva.BeCommentUser__c;
        }
    }
}