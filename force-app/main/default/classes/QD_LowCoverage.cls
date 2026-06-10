public with sharing class QD_LowCoverage {
    public static Integer riskyDivide(Integer x, Integer y) {
        if (y == 0) {
            return null;
        }
        return x / y;
    }
}