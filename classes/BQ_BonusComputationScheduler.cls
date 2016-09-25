/*
Created on：2011-1-16
Description: 
1.计划执行BQ的奖金计算
*/
global class BQ_BonusComputationScheduler implements Schedulable{
	global static final String CRON_EXP = '0 0 1 * * ?';
	global void execute(SchedulableContext sc) 
	{
		Integer year = Date.today().year();
		Integer month = Date.today().month();
		BQ_BatchComputationBonus BonusBatch = new BQ_BatchComputationBonus();
		BonusBatch.year = year;
		BonusBatch.month = month;
		Database.executeBatch(BonusBatch,1);
	}
}