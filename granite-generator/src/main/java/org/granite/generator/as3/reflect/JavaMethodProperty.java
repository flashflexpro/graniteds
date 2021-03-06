/**
 *   GRANITE DATA SERVICES
 *   Copyright (C) 2006-2015 GRANITE DATA SERVICES S.A.S.
 *
 *   This file is part of the Granite Data Services Platform.
 *
 *   Granite Data Services is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) any later version.
 *
 *   Granite Data Services is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
 *   General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
 *   USA, or see <http://www.gnu.org/licenses/>.
 */
package org.granite.generator.as3.reflect;

import java.lang.annotation.Annotation;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.granite.generator.as3.ClientType;
import org.granite.generator.as3.PropertyType;
import org.granite.messaging.annotations.Include;
import org.granite.util.ClassUtil;

/**
 * @author Franck WOLFF
 */
public class JavaMethodProperty implements JavaProperty {

    private final String name;
    private final JavaMethod readMethod;
    private final JavaMethod writeMethod;
    private final Class<?> type;
    private final Type genericType;
    private final ClientType clientType;
    private final boolean externalizedProperty;

    public JavaMethodProperty(JavaTypeFactory provider, String name, JavaMethod readMethod, JavaMethod writeMethod) {
    	this(provider, name, readMethod, writeMethod, null);
    }
    
    public JavaMethodProperty(JavaTypeFactory provider, String name, JavaMethod readMethod, JavaMethod writeMethod, ParameterizedType declaringType) {
        if (name == null || (readMethod == null && writeMethod == null))
            throw new NullPointerException("Invalid parameters");
        this.name = name;
        this.readMethod = readMethod;
        this.writeMethod = writeMethod;
        Type genericType = (
            readMethod != null ?
            readMethod.getMember().getGenericReturnType() :
            writeMethod.getMember().getGenericParameterTypes()[0]
        );
        Class<?> declaringClass = readMethod != null ? readMethod.getMember().getDeclaringClass() : writeMethod.getMember().getDeclaringClass();
    	if (genericType instanceof TypeVariable && declaringType != null) {
    		int index = -1;
    		for (int i = 0; i < declaringClass.getTypeParameters().length; i++) {
    			if (declaringClass.getTypeParameters()[i] == genericType) {
    				index = i;
    				break;
    			}
    		}
    		if (index >= 0 && index < declaringType.getActualTypeArguments().length)
    			genericType = declaringType.getActualTypeArguments()[index];
    	}
        this.type = ClassUtil.classOfType(genericType);
        this.genericType = genericType;
        ClientType clientType = provider.getClientType(genericType, null, null, isWritable() ? PropertyType.PROPERTY : PropertyType.READONLY_PROPERTY);
        if (clientType == null)
        	clientType = provider.getAs3Type(type);
        this.clientType = clientType;
        this.externalizedProperty = (
        	readMethod != null &&
        	ClassUtil.isAnnotationPresent(readMethod.getMember(), Include.class)
        );
    }

    public String getAccess() {
        return JavaMember.PRIVATE;
    }

    @Override
	public String getName() {
        return name;
    }
    
    @Override
	public String getCapitalizedName() {
    	return getName().substring(0, 1).toUpperCase() + getName().substring(1);
    }

    @Override
	public Class<?> getType() {
        return type;
    }
    
    public Type getGenericType() {
    	return genericType;
    }
    
    @Override
	public Type[] getGenericTypes() {
		Type type = readMethod != null ? readMethod.getMember().getGenericReturnType() : writeMethod.getMember().getGenericParameterTypes()[0];
		if (!(type instanceof ParameterizedType))
			return null;
		return ((ParameterizedType)type).getActualTypeArguments();
    }

    @Override
	public boolean isReadable() {
        return (readMethod != null);
    }

    @Override
	public boolean isWritable() {
        return (writeMethod != null);
    }

    @Override
	public boolean isExternalizedProperty() {
        return externalizedProperty;
    }

    @Override
	public boolean isEnum() {
		return (type.isEnum() || Enum.class.getName().equals(type.getName()));
	}

	@Override
	public boolean isAnnotationPresent(Class<? extends Annotation> annotationClass) {
        return (
            (readMethod != null && readMethod.getMember().isAnnotationPresent(annotationClass)) ||
            (writeMethod != null && writeMethod.getMember().isAnnotationPresent(annotationClass))
        );
    }

    @Override
	public <T extends Annotation> T getAnnotation(Class<T> annotationClass) {
    	T annotation = null;
    	if (readMethod != null) {
    		annotation = readMethod.getMember().getAnnotation(annotationClass);
    		if (annotation != null)
    			return annotation;
    	}
    	if (writeMethod != null) {
    		annotation = writeMethod.getMember().getAnnotation(annotationClass);
    		if (annotation != null)
    			return annotation;
    	}
    	return null;
    }
    
    @Override
	public Annotation[] getDeclaredAnnotations() {
    	List<Annotation> annos = new ArrayList<Annotation>();
    	if (readMethod != null)
    		annos.addAll(Arrays.asList(readMethod.getMember().getDeclaredAnnotations()));
    	if (writeMethod != null)
    		annos.addAll(Arrays.asList(writeMethod.getMember().getDeclaredAnnotations()));
    	return annos.toArray(new Annotation[0]);
    }

    @Override
	public boolean isReadOverride() {
        return (readMethod != null && readMethod.isOverride());
    }

    @Override
	public boolean isWriteOverride() {
        return (writeMethod != null && writeMethod.isOverride());
    }

    @Override
	public JavaMethod getReadMethod() {
        return readMethod;
    }

    @Override
	public JavaMethod getWriteMethod() {
        return writeMethod;
    }

    public ClientType getAs3Type() {
        return clientType;
    }

    @Override
	public ClientType getClientType() {
        return clientType;
    }

    @Override
	public int compareTo(JavaProperty o) {
        return name.compareTo(o.getName());
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj instanceof JavaMethodProperty)
            return ((JavaMethodProperty)obj).name.equals(name);
        return false;
    }

    @Override
    public int hashCode() {
        return name.hashCode();
    }
}
