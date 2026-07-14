public with sharing class ConditionExecutor implements ManualConditionValidator
{
    public boolean validateCondition()
    {
        System.debug('Hello');
        return true;
    }
}