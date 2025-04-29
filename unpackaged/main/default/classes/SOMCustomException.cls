/**
 * @description       : 
 * @author            : walid abidi
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : walid abidi
**/
public with sharing class SOMCustomException  extends Exception {
     
    public String apexclassName;
     public String methodName;
     
  
    public SOMCustomException(String message,String apexclassName,String methodName) {
      this(message);
      this.apexclassName=apexclassName;
      this.methodName=methodName;
 
    } 
}