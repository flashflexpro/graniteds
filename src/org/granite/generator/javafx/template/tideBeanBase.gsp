<%--
  GRANITE DATA SERVICES
  Copyright (C) 2011 GRANITE DATA SERVICES S.A.S.

  This file is part of Granite Data Services.

  Granite Data Services is free software; you can redistribute it and/or modify
  it under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  Granite Data Services is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, see <http://www.gnu.org/licenses/>.

  @author Franck WOLFF
--%><%
    Set javaImports = new TreeSet();

	javaImports.add("org.granite.client.javafx.JavaFXObject");
	
    if (!jClass.hasSuperclass()) {
    	javaImports.add("javafx.event.Event");
    	javaImports.add("javafx.event.EventDispatchChain");
    	javaImports.add("javafx.event.EventHandler");
    	javaImports.add("javafx.event.EventType");
    	javaImports.add("com.sun.javafx.event.EventHandlerManager");

    	javaImports.add("org.granite.client.util.javafx.DataNotifier");
    }
	
    for (jProperty in jClass.properties) {
        if (jClass.metaClass.hasProperty(jClass, 'constraints') && jClass.constraints[jProperty] != null) {
        	for (cons in jClass.constraints[jProperty])
        		javaImports.add(cons.packageName + "." + cons.name);
        }
    }

    for (jImport in jClass.imports) {
        if (jImport.hasImportPackage() && jImport.importPackageName != "java.lang" && jImport.importPackageName != jClass.clientType.packageName)
            javaImports.add(jImport.importQualifiedName);
    }

%>/**
 * Generated by Gas3 v${gVersion} (Granite Data Services).
 *
 * WARNING: DO NOT CHANGE THIS FILE. IT MAY BE OVERWRITTEN EACH TIME YOU USE
 * THE GENERATOR. INSTEAD, EDIT THE INHERITED CLASS (${jClass.as3Type.name}.as).
 */

package ${jClass.clientType.packageName};
<%
///////////////////////////////////////////////////////////////////////////////
// Write Import Statements.

    for (javaImport in javaImports) {%>
import ${javaImport};<%
    }
    if (jClass.clientSuperclass != null) {%>
import ${jClass.clientSuperclass.qualifiedName};<%
    }
///////////////////////////////////////////////////////////////////////////////
// Write Class Declaration.%>

@JavaFXObject
public class ${jClass.clientType.name}Base<%

        boolean implementsWritten = false;
        if (jClass.superclass != null) {
            %> extends ${jClass.superclass.clientType.name}<%
        } else {
        	if (jClass.clientSuperclass != null) {
        	%> extends ${jClass.clientSuperclass.name}<%
        	}
            %> implements DataNotifier<%

            implementsWritten = true;
        }

        for (jInterface in jClass.interfaces) {
            if (!implementsWritten) {
                %> implements ${jInterface.clientType.name}<%

                implementsWritten = true;
            } else {
                %>, ${jInterface.clientType.name}<%
            }
        }

    %> {
	
	private EventHandlerManager __handlerManager = new EventHandlerManager(this); 

	@Override
	public EventDispatchChain buildEventDispatchChain(EventDispatchChain tail) {
		return tail.prepend(__handlerManager);
	}
	
	public <T extends Event> void addEventHandler(EventType<T> type, EventHandler<? super T> handler) {
		__handlerManager.addEventHandler(type, handler);
	}
	public <T extends Event> void removeEventHandler(EventType<T> type, EventHandler<? super T> handler) {
		__handlerManager.removeEventHandler(type, handler);
	}
	
<%

    ///////////////////////////////////////////////////////////////////////////
    // Write Private Fields.
	
	%>
	@SuppressWarnings("unused")
	private static final String[] __externalizedProperties = { <%
		jClass.properties.eachWithIndex { jProperty, idx -> if (idx > 0) { %>, <% } %>"${jProperty.name}"<% }
	%> };
	<%

    for (jProperty in jClass.properties) {
        if (jProperty instanceof org.granite.generator.as3.reflect.JavaMember && jProperty.clientType.propertyTypeName != null) {%>
    ${jProperty.access} ${jProperty.clientType.simplePropertyTypeName} ${jProperty.name} = new ${jProperty.clientType.simplePropertyImplTypeName}(this, "${jProperty.name}");<%
        }
        else if (jProperty instanceof org.granite.generator.as3.reflect.JavaMember && jProperty.clientType.propertyTypeName == null) {%>
    ${jProperty.access} ${jProperty.clientType.name} ${jProperty.name} = new ${jProperty.clientType.simplePropertyImplTypeName}();<%
        }
        else if (jProperty.clientType.propertyTypeName != null) {%>
    private ${jProperty.clientType.simplePropertyTypeName} ${jProperty.name} = new ${jProperty.clientType.simplePropertyImplTypeName}(this, "${jProperty.name}");<%
        }
    }%>
    <%

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getter/Setter.

    for (jProperty in jClass.properties) {
        if (jProperty.readable || jProperty.writable) {
        	if (jProperty.clientType.propertyTypeName != null) {%>
	public ${jProperty.clientType.simplePropertyTypeName} ${jProperty.name}Property() {
		return ${jProperty.name};
	}<%
        	}
            if (jProperty.writable) {
            	if (jProperty.writeOverride) {%>
    @Override<% } %>
    public void set${jProperty.capitalizedName}(${jProperty.clientType.name} value) {<%
    			if (jProperty.clientType.propertyTypeName != null) {%>
        ${jProperty.name}.set(value);<%
    			}
    			else {%>
    	this.${jProperty.name} = value;<%			
    			}%>
    }<%
            }
            if (jProperty.readable) {
                if (jClass.metaClass.hasProperty(jClass, 'constraints') && jClass.constraints[jProperty] != null) {
                	for (cons in jClass.constraints[jProperty]) {%>
    @${cons.name}<%
    					if (!cons.properties.empty) {%>(<%}
    					cons.properties.eachWithIndex{ p, i -> if (i > 0) {%>, <%}; if (p[2] == "java.lang.String") {%>${p[0]}="${p[1]}"<% } else { %>${p[0]}=${p[1]}<% } }
    					if (!cons.properties.empty) {%>)<%}
    				}
                }
            	if (jProperty.readOverride) {%>
    @Override<% } %>
    public ${jProperty.clientType.name} get${jProperty.capitalizedName}() {<%
				if (jProperty.clientType.propertyTypeName != null) {%>
        return ${jProperty.name}.get();<%
				}
				else {%>
		return this.${jProperty.name};<%
				}%>
    }
    <%
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getters/Setters for Implemented Interfaces.

    if (jClass.hasInterfaces()) {
        for (jProperty in jClass.interfacesProperties) {
            if (jProperty.readable || jProperty.writable) {%>
<%
                if (jProperty.writable) {%>
    public void set${jProperty.capitalizedName}(${jProperty.clientType.name} value) {
    }<%
                }
                if (jProperty.readable) {%>
    public ${jProperty.clientType.name} get${jProperty.capitalizedName}() {
        return ${jProperty.clientType.nullValue};
    }<%
                }
            }
        }
    }%>
}