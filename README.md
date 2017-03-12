Flashflexpro Simple AMF
=========================

A simple implementation for convert Java Object into/from AMF binary based on GraniteDS

Simple AMF does one thing, to convert Java Object into/from AMF byte array java.nio.ByteBuffer.

This lib is using a copy from GraniteDS's source, make as few changes as possible, please see the history for details.


Quick Start
-----------


### Maven configuration

Add the Maven dependency:

```xml
<dependency>
    <groupId>com.flashflexpro</groupId>
    <artifactId>simple-amf-all</artifactId>
    <version>0.0.1</version>
</dependency>
```


### Simple example:

```java
public class DtoRegisterForm{
    
    private String username;
    private Date birthday;
    private String[] interests;
}
```


You have a DTO object dtoObj to transfer to Actionscript client:

```java
    RegexAMF3DeserializerSecurizer securizer = new RegexAMF3DeserializerSecurizer();
    //only deserialize Java Classes in package org.graniteds and com.flashflexpro
    securizer.setParam( '(^org\.graniteds\..+|^com\.flashflexpro\..+)');
    sgc = new SimpleGraniteConfig( securizer );
    ByteBuffer dtoObjInAmf = sgc.encode( dtoObj );
    //then pass dtoObjInAmf to client in anyway
```

### Security First !!! Data from client side can't be trusted !!! 

The more help we get, the less control we have, before using this lib, please make sure you understand 

https://www.owasp.org/index.php/Deserialization_of_untrusted_data
 
There is no clear general line to define a threat, but at least we should 1) verify session identification before deserialize; 2) Limit the classes that can be deserialized;


### Actionscript has fewer primary types than Java 

So when converting Actionscript Number type to Java type, it needs to be converted sometimes to determine what type programmer want, which means Java side needs to provide extra infomation, when that information is provided, Java side need to do type conversion which GraniteDS already implemented.

### More sophisticated assistant libraries that based on Simple AMF will be in other projects