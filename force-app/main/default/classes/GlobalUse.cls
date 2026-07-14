public class GlobalUse
{
    public GlobalUse()
    {
        TempTest.TestUtils tu = new TempTest.TestUtils();
        TempTest.TestUtils.Result rr = tu.getResult('sdfs');
        System.debug(rr);
        System.debug(rr.isSuccess);
        System.debug(rr.infoMessage);
        System.debug(rr.errorMessage);
        System.debug(rr.needToUpdate);
        System.debug(rr.details);
        System.debug(rr.details.Id);
        System.debug(rr.details.Name);
    }
}