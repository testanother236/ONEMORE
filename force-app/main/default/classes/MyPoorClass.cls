// File: classes/MyPoorClass.cls
public with sharing class MyPoorClass {
    public static String riskyMethod(String s) {
        if(s == null) return 'null';
        return s + '!';
    }
}