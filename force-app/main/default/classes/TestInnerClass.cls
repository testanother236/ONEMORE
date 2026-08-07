
/**
 * Demonstrates a minimal public Apex class with a logging constructor.
 */
public class TestInnerClass {
    /**
     * Initializes a new instance of TestInnerClass and writes a debug log entry.
     */
    public TestInnerClass() {
        system.debug('Constructor');
    }
}
