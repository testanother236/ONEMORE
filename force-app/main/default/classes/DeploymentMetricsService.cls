public with sharing class DeploymentMetricsService {

    public class DeploymentResult {
        public String deploymentName;
        public Integer totalComponents;
        public Integer failedComponents;
        public Boolean success;
    }

    public static DeploymentResult analyzeDeployment(
        String deploymentName,
        Integer totalComponents,
        Integer failedComponents
    ) {
        DeploymentResult result = new DeploymentResult();

        result.deploymentName = deploymentName;
        result.totalComponents = totalComponents;
        result.failedComponents = failedComponents;
        result.success = failedComponents == 0;

        if (totalComponents == null || totalComponents <= 0) {
            throw new IllegalArgumentException('Total components must be greater than zero.');
        }

        Decimal failureRate =
            (Decimal.valueOf(failedComponents) / Decimal.valueOf(totalComponents)) * 100;

        System.debug('Deployment analyzed: ' + deploymentName);
        System.debug('Failure rate: ' + failureRate.setScale(2) + '%');

        return result;
    }

    public static List<String> collectWarnings(List<String> componentNames) {
        List<String> warnings = new List<String>();

        for (String componentName : componentNames) {
            if (componentName != null && componentName.endsWith('__c')) {
                warnings.add('Custom object detected: ' + componentName);
            }
        }

        return warnings;
    }
}