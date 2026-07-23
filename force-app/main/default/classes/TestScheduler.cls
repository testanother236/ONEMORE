// Тестовый класс планировщика
public class TestScheduler implements Schedulable, BatchScheduler {
    public String batchClassName;

    public void setBatchClassName(String batchClassName) {
        this.batchClassName = batchClassName;
    }

    public void execute(SchedulableContext sc) {
        // Логика выполнения планировщика (можно оставить пустым для теста)
    }
}