global class NxlEnforcerJob implements Schedulable 
{
    Integer m_intervalHours;
    public NxlEnforcerJob (Integer intervalHours) 
    {
        m_intervalHours = intervalHours;
    }
    public void execute(SchedulableContext sc) 
    {       
        System.Debug('NxlEnforcerJob begin to execute.');
        NxlCommonGlobal.CheckUserObligation(); // call future method do evaluation for all records by policy.               
        
        // Re-schedule ourself to run again in "intervalMinutes" time
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addHours(m_intervalHours);
        String cronString = nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() 
            + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        System.schedule(NxlEnforcerJob.class.getName() + '-' + now.format(), cronString, new NxlEnforcerJob(m_intervalHours));
        
        // Abort the current job
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);
    }
}