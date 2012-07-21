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
    Set as3Imports = new TreeSet();

    as3Imports.add("flash.utils.IDataInput");
    as3Imports.add("flash.utils.IDataOutput");

    if (!jClass.hasSuperclass())
        as3Imports.add("flash.utils.IExternalizable");

    if (jClass.hasEnumProperty())
        as3Imports.add("org.granite.util.Enum");

    for (jImport in jClass.imports) {
        if (jImport.as3Type.hasPackage() && jImport.as3Type.packageName != jClass.as3Type.packageName)
            as3Imports.add(jImport.as3Type.qualifiedName);
    }

%>/**
 * Generated by Gas3 v${gVersion} (Granite Data Services).
 *
 * WARNING: DO NOT CHANGE THIS FILE. IT MAY BE OVERWRITTEN EACH TIME YOU USE
 * THE GENERATOR. INSTEAD, EDIT THE INHERITED CLASS (${jClass.as3Type.name}.as).
 */

package ${jClass.as3Type.packageName} {
<%
///////////////////////////////////////////////////////////////////////////////
// Write Import Statements.

    for (as3Import in as3Imports) {%>
    import ${as3Import};<%
    }
    if (jClass.as3Superclass != null) {%>
    import ${jClass.as3Superclass.qualifiedName};<%
    }

///////////////////////////////////////////////////////////////////////////////
// Write Class Declaration.%>

    [Bindable]
    public class ${jClass.as3Type.name}Base<%

        boolean implementsWritten = false;
        if (jClass.superclass != null) {
            %> extends ${jClass.superclass.as3Type.name}<%
        } else {
        	if (jClass.as3Superclass != null) {
        	%> extends ${jClass.as3Superclass.name}<%
        	}
            %> implements IExternalizable<%

            implementsWritten = true;
        }

        for (jInterface in jClass.interfaces) {
            if (!implementsWritten) {
                %> implements ${jInterface.as3Type.name}<%

                implementsWritten = true;
            } else {
                %>, ${jInterface.as3Type.name}<%
            }
        }

    %> {
<%

    ///////////////////////////////////////////////////////////////////////////
    // Write Private Fields.

    for (jProperty in jClass.properties) {
        if (jProperty instanceof org.granite.generator.as3.reflect.JavaMember) {%>
        ${jProperty.access} var _${jProperty.name}:${jProperty.as3Type.name};<%
        }
        else {%>
        private var _${jProperty.name}:${jProperty.as3Type.name};<%
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write Public Getter/Setter.

    for (jProperty in jClass.properties) {
        if (jProperty.readable || jProperty.writable) {%>
<%
            if (jProperty.writable) {%>
        public <%= jProperty.writeOverride ? "override " : "" %>function set ${jProperty.name}<% if (jProperty.name == jProperty.as3Type.name) { %>_<% } %>(value:${jProperty.as3Type.name}):void {
            _${jProperty.name} = value;
        }<%
            }
            if (jProperty.readable) {
                if (!jProperty.writable) {%>
        [Bindable(event="unused")]<%
    			}
                if (jClass.metaClass.hasProperty(jClass, 'constraints') && jClass.constraints[jProperty] != null) {
                	for (cons in jClass.constraints[jProperty]) {%>
    	[${cons.name}<%
    					if (!cons.properties.empty) {%>(<%}
    					cons.properties.eachWithIndex{ p, i -> if (i > 0) {%>, <%}%>${p[0]}="${p[1]}"<%}
    					if (!cons.properties.empty) {%>)<%}%>]<%
    				}
                }%>
        public <%= jProperty.readOverride ? "override " : "" %>function get ${jProperty.name}<% if (jProperty.name == jProperty.as3Type.name) { %>_<% } %>():${jProperty.as3Type.name} {
            return _${jProperty.name};
        }<%
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
        public function set ${jProperty.name}(value:${jProperty.as3Type.name}):void {
        }<%
                }
                if (jProperty.readable) {%>
        public function get ${jProperty.name}():${jProperty.as3Type.name} {
            return ${jProperty.as3Type.nullValue};
        }<%
                }
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////
    // Write IExternalizable Implementation.%>

        public <%= (jClass.hasSuperclass() ? "override " : "") %>function readExternal(input:IDataInput):void {<%

    if (jClass.hasSuperclass()) {%>
            super.readExternal(input);<%
    }
    for (jProperty in jClass.properties) {
        if (jProperty.as3Type.isNumber()) {%>
            _${jProperty.name} = function(o:*):Number { return (o is Number ? o as Number : Number.NaN) } (input.readObject());<%
        }
        else if (jProperty.isEnum()) {%>
            _${jProperty.name} = Enum.readEnum(input) as ${jProperty.as3Type.name};<%
        }
        else {%>
            _${jProperty.name} = input.readObject() as ${jProperty.as3Type.name};<%
        }
    }%>
        }

        public <%= (jClass.hasSuperclass() ? "override " : "") %>function writeExternal(output:IDataOutput):void {<%

    if (jClass.hasSuperclass()) {%>
            super.writeExternal(output);<%
    }
    for (jProperty in jClass.properties) {%>
            output.writeObject(_${jProperty.name});<%
    }%>
        }
    }
}